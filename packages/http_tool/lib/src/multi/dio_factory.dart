import 'package:http_tool/src/core/dio_client.dart';
import 'package:http_tool/src/core/network_config.dart';

class DioFactory {
  static final Map<String, DioClient> _clients = {};

  static DioClient getClient(String key, NetworkConfig config) {
    return _clients.putIfAbsent(key, () => DioClient(config));
  }
}
