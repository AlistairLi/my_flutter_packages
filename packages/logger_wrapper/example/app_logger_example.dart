import 'package:logger_wrapper/logger_wrapper.dart';

void main() {
  // mLog("Hello World");
  // mLogV("Hello World");
  // mLogW("Hello World");
  // mLogE("Hello World");
  var list = [1, 2, 3, 4, 5];
  var iterable = list.where((element) => element==6);
  mLog(iterable.length);
}
