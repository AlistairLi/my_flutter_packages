import 'package:google_adid/src/gid_platform_interface.dart';
import 'package:google_adid/src/gid_result_model.dart';

class Gid {
  Future<String?> getPlatformVersion() {
    return GidPlatform.instance.getPlatformVersion();
  }

  Future<GidResultModel> getGid() {
    return GidPlatform.instance.getGid();
  }
}
