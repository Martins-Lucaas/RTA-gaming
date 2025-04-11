// web_title_switcher_web.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/material.dart';

class WebTitleSwitcher extends StatefulWidget {
  const WebTitleSwitcher({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<WebTitleSwitcher> createState() => _WebTitleSwitcherWebState();
}

class _WebTitleSwitcherWebState extends State<WebTitleSwitcher> {
  bool _isTabActive = true;

  @override
  void initState() {
    super.initState();
    // Registra eventos de perda e ganho de foco
    html.window.addEventListener('blur', _handleBlurEvent);
    html.window.addEventListener('focus', _handleFocusEvent);

    // Funcionalidade A2HS
    listenToBeforeInstallPromptEvent();
  }

  @override
  void dispose() {
    // Remove os ouvintes de eventos
    html.window.removeEventListener('blur', _handleBlurEvent);
    html.window.removeEventListener('focus', _handleFocusEvent);
    super.dispose();
  }

  void _handleBlurEvent(html.Event event) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isTabActive = false;
        });
        _updateTabTitle();
      }
    });
  }

  void _handleFocusEvent(html.Event event) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isTabActive = true;
        });
        _updateTabTitle();
      }
    });
  }

  void _updateTabTitle() {
    final String title = _isTabActive ? "RTA GAMING" : "Cortar FRUTINHAS 🍎";
    html.document.title = title;
  }

  void listenToBeforeInstallPromptEvent() {
    html.window.on['beforeinstallprompt'].listen((event) {
      // Impede que a mini-infobar apareça no mobile
      event.preventDefault();

      // Cria um botão de instalação
      html.ButtonElement installButton = html.ButtonElement()
        ..text = "Adicionar à Tela Inicial"
        ..style.position = "fixed"
        ..style.bottom = "10px"
        ..style.left = "10px";

      // Adiciona o botão ao body
      html.document.body?.append(installButton);

      // Quando o botão é clicado, dispara o prompt
      installButton.onClick.listen((_) {
        js.JsObject.fromBrowserObject(event).callMethod('prompt');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
