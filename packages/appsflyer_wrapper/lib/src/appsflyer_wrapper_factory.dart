import 'package:appsflyer_wrapper/src/appsflyer_wrapper_service.dart';
import 'package:appsflyer_wrapper/src/interfaces/af_config_interface.dart';
import 'package:appsflyer_wrapper/src/interfaces/af_error_interface.dart';

class AFWrapperFactory {
  AFWrapperFactory._();

  static AFWrapperService create({
    required AFConfigInterface config,
    required AFErrorInterface error,
  }) {
    return AFWrapperService(
      config: config,
      error: error,
    );
  }
}
