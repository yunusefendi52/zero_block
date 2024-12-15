import 'package:zero_block/utils/utils.all.dart'
    if (dart.library.html) 'package:zero_block/utils/utils.web.dart' as u;

String? getPlayShareLevel() {
  return u.getPlayShareLevel();
}

void removePlayShareLevel() {
  return u.removePlayShareLevel();
}
