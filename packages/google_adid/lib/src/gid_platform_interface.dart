import 'package:google_adid/src/gid_result_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'gid_method_channel.dart';

abstract class GidPlatform extends PlatformInterface {
  /// Constructs a GidPlatform.
  GidPlatform() : super(token: _token);

  static final Object _token = Object();

  static GidPlatform _instance = MethodChannelGid();

  /// The default instance of [GidPlatform] to use.
  ///
  /// Defaults to [MethodChannelGid].
  static GidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GidPlatform] when
  /// they register themselves.
  static set instance(GidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<GidResultModel> getGid() {
    throw UnimplementedError('getGid() has not been implemented.');
  }
}
