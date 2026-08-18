import 'package:get/get.dart';
import 'package:outmed/config/bindings/initial_binding.dart';

abstract final class Injection {
  static Bindings get initialBinding => InitialBinding();
}
