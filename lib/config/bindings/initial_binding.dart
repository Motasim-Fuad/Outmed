import 'package:get/get.dart';
import 'package:outmed/features/auth/presentation/controllers/auth_controller.dart';
import 'package:outmed/features/cart/presentation/controllers/cart_controller.dart';
import 'package:outmed/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:outmed/features/orders/presentation/controllers/order_controller.dart';
import 'package:outmed/features/supplier/presentation/controllers/supplier_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CatalogRepository>(CatalogRepositoryImpl(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(CatalogController(Get.find<CatalogRepository>()), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(OrderController(), permanent: true);
    Get.put(SupplierController(Get.find<CatalogRepository>()), permanent: true);
  }
}
