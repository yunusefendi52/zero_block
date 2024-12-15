// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
