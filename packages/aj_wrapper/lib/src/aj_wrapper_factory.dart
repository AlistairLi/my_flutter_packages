import 'package:aj_wrapper/src/aj_wrapper_service.dart';
import 'package:aj_wrapper/src/interfaces/aj_config_interface.dart';
import 'package:aj_wrapper/src/interfaces/aj_error_interface.dart';
import 'package:aj_wrapper/src/interfaces/aj_storage_interface.dart';

class AJWrapperFactory {
  AJWrapperFactory._();

  static AJWrapperService create({
    required AJStorageInterface storage,
    required AJConfigInterface config,
    required AJErrorInterface error,
  }) {
    return AJWrapperService(
      storage: storage,
      config: config,
      error: error,
    );
  }
}
