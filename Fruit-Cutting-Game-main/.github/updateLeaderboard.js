const fs = require('fs');

module.exports = async ({ github, context }) => {
    try {
        console.log('Starting leaderboard update...');

        const query = `query($owner:String!, $name:String!, $issue_number:Int!) {
          repository(owner:$owner, name:$name){
            issue(number:$issue_number) {
              title
              bodyText
              author {
                avatarUrl(size: 24)
                login
                url
              }
              updatedAt
            }
          }
        }`;

        const variables = {
          owner: context.repo.owner,
          name: context.repo.repo,
          issue_number: context.issue.number,
        };

        const result = await github.graphql(query, variables);
        console.log(JSON.stringify(result, null, 2));

        const issue = result.repository.issue;

        const nameMatch = /👤 Name:(.*?)\n-/.exec(issue.bodyText);
        const githubLinkMatch = /🔗 GitHub Profile Link:(.*?)\n-/.exec(issue.bodyText);
        const messageMatch = /💬 Message:(.*?)\n-/.exec(issue.bodyText);
        const scoreMatch = /Score:\s*(\d+)/.exec(issue.title);
        const dateMatch = /Game Result Submission:\s*(.*?) - Score:/.exec(issue.title);
        const modeMatch = /Mode:\s*(\d+)/.exec(issue.title);
        const winMatch = /Win:\s*(\d+)/.exec(issue.title);

        // Extract values or fallback to author details if null
        const name = nameMatch && nameMatch[1].trim() !== '' ? nameMatch[1].trim() : issue.author.login;
        const githubLink = githubLinkMatch && githubLinkMatch[1].trim() !== '' ? githubLinkMatch[1].trim() : issue.author.url;
        const message = messageMatch ? messageMatch[1].trim() : 'Happy playing 🎉 !!!';
        const score = scoreMatch ? parseInt(scoreMatch[1].trim()) : null;
        const date = dateMatch ? dateMatch[1].trim() : null;
        const mode = modeMatch ? parseInt(modeMatch[1].trim()) : null;
        const win = winMatch ? parseInt(winMatch[1].trim()) : null;

        // Check for null values
        if (score === null || date === null || mode === null || win === null) {
            console.log('One or more required fields are missing. Stopping further processing.');
            return false;
        }

        // Map mode values to difficulty levels
        const modeMapping = {
          0: 'Easy',
          1: 'Medium',
          2: 'Hard'
        };

        const difficulty = modeMapping[mode] || '';
        const gameOutcome = win === 1 ? 'Win' : 'Game Over';

        const newLeaderboardItem = `| ${score} | ${difficulty} | [<img src="${issue.author.avatarUrl}" alt="${issue.author.login}" width="24" /> ${name}](${githubLink}) | ${message} | ${date} |`;
        const newEntry = `| ${date} | [<img src="${issue.author.avatarUrl}" alt="${issue.author.login}" width="24" /> ${name}](${githubLink}) | ${message} | ${difficulty} | ${score} | ${gameOutcome} |`;

        const readmePath = 'README.md';
        let readme = fs.readFileSync(readmePath, 'utf8');

        // Update Recent Plays
        const recentPlaysSection = /<!-- Recent Plays -->[\s\S]*?<!-- \/Recent Plays -->/.exec(readme);
        if (recentPlaysSection) {
            let recentPlaysContent = recentPlaysSection[0];

            let recentPlaysRows = recentPlaysContent
                .split('\n')
                .filter(row => row.startsWith('|') && !row.includes('Date | Player | Message | Game Mode | Score | Status ') && !row.includes('|------|--------|---------|-----------|-------|--------|'));

            recentPlaysRows.unshift(newEntry);

            if (recentPlaysRows.length > 20) {
                recentPlaysRows = recentPlaysRows.slice(0, 20);
            }

            const updatedRecentPlays = `<!-- Recent Plays -->\n| Date | Player | Message | Game Mode | Score | Status |\n|------|--------|---------|-----------|-------|--------|\n${recentPlaysRows.join('\n')}\n<!-- /Recent Plays -->`;
            readme = readme.replace(recentPlaysSection[0], updatedRecentPlays);
        }

        // Update Leaderboard
        const leaderboardSection = /<!-- Leaderboard -->[\s\S]*?<!-- \/Leaderboard -->/.exec(readme);
        if (leaderboardSection && win === 1) {
            let leaderboardContent = leaderboardSection[0];

            let leaderboardRows = leaderboardContent
                .split('\n')
                .filter(row => row.startsWith('|') && !row.includes('Score | Game Mode | Player | Message | Date') && !row.includes('|-------|-----------|--------|---------|------|'));

            leaderboardRows.unshift(newLeaderboardItem);

            leaderboardRows.sort((a, b) => {
                const scoreA = parseInt(a.split('|')[1].trim(), 10);
                const scoreB = parseInt(b.split('|')[1].trim(), 10);
                const dateA = new Date(a.split('|')[5].trim());
                const dateB = new Date(b.split('|')[5].trim());

                return scoreB - scoreA || dateB - dateA;
            });

            if (leaderboardRows.length > 20) {
                leaderboardRows = leaderboardRows.slice(0, 20);
            }

            const updatedLeaderboard = `<!-- Leaderboard -->\n| Score | Game Mode | Player | Message | Date |\n|-------|-----------|--------|---------|------|\n${leaderboardRows.join('\n')}\n<!-- /Leaderboard -->`;
            readme = readme.replace(leaderboardSection[0], updatedLeaderboard);
        }

        fs.writeFileSync(readmePath, readme, 'utf8');
        console.log('README.md updated successfully.');

        return true;
    } catch (error) {
        console.error('Error:', error);
        return false;
    }
};
