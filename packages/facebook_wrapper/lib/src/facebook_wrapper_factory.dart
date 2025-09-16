import 'package:facebook_wrapper/facebook_wrapper.dart';

class FacebookWrapperFactory {
  FacebookWrapperFactory._();

  static FacebookWrapperService create({
    required FacebookConfigInterface config,
    required FacebookErrorInterface error,
  }) {
    return FacebookWrapperService(
      config: config,
      error: error,
    );
  }
}
