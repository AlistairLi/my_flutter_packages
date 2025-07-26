import 'package:flutter_test/flutter_test.dart';
import 'package:google_adid/src/gid.dart';
import 'package:google_adid/src/gid_method_channel.dart';
import 'package:google_adid/src/gid_platform_interface.dart';
import 'package:google_adid/src/gid_result_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGidPlatform with MockPlatformInterfaceMixin implements GidPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<GidResultModel> getGid() async {
    return GidResultModel("", 0, "测试");
  }
}

void main() {
  final GidPlatform initialPlatform = GidPlatform.instance;

  test('$MethodChannelGid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGid>());
  });

  test('getPlatformVersion', () async {
    Gid gidPlugin = Gid();
    MockGidPlatform fakePlatform = MockGidPlatform();
    GidPlatform.instance = fakePlatform;

    expect(await gidPlugin.getPlatformVersion(), '42');
  });
}
