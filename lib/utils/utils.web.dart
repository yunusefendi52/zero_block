// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as dart_js;

html.Element? _getMetaTag() {
  return html.document.querySelector('meta[name="playShareLevelTag"]');
}

String? getPlayShareLevel() {
  final metaTag = _getMetaTag();
  final content = metaTag?.getAttribute('content');
  return content;
}

void removePlayShareLevel() {
  final metaTag = _getMetaTag();
  metaTag?.remove();
}

void showMainMenu() {
  final data = {
    'type': 'actionMainMenu',
  };
  parentPostMessage(data);
}

void parentPostMessage(dynamic message) {
  html.window.parent!.postMessage(message, '*');
}
