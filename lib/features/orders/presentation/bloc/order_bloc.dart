import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/constants/app_durations.dart';
import 'package:outmed/core/extensions/iterable_x.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc(this._catalog, this._cart) : super(OrderState(orders: _seed)) {
    on<OrderStarted>(_start);
    on<OrderPlaceRequested>(_place);
    on<OrderBuyAgainRequested>(_buyAgain);
    on<OrderStatusAdvanced>(_advance);
    add(const OrderStarted());
  }

  final CatalogRepository _catalog;
  final CartBloc _cart;

  List<OrderModel> get orders => state.orders;

  static final _seed = [
    OrderModel(
      id: 'ORD-2024-1058',
      buyerName: 'King Fahad Hospital',
      supplierName: 'HealthCare Supplies',
      productName: 'Nitrile Examination Gloves (M)',
      quantity: 12,
      total: 540,
      createdAt: DateTime(2026, 8, 18, 9, 32),
      status: OrderStatus.pending,
      productId: 'examination-set',
      offerId: 'offer-5',
    ),
    OrderModel(
      id: 'ORD-2024-1059',
      buyerName: 'Riyadh Medical Center',
      supplierName: 'HealthCare Supplies',
      productName: 'Disposable Syringe 5ml',
      quantity: 8,
      total: 256,
      createdAt: DateTime(2026, 8, 17, 14, 10),
      status: OrderStatus.confirmed,
      productId: 'syringe-5ml',
      offerId: 'offer-4',
    ),
    OrderModel(
      id: 'ORD-2024-1060',
      buyerName: 'Al Salma Hospital',
      supplierName: 'HealthCare Supplies',
      productName: 'Clinical Diagnostic Kit',
      quantity: 3,
      total: 435,
      createdAt: DateTime(2026, 8, 16, 11, 45),
      status: OrderStatus.inTransit,
      productId: 'diagnostic-kit',
      offerId: 'offer-1',
    ),
  ];

  Future<void> _start(OrderStarted event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading, revision: state.revision + 1));
    if (!AppEnv.isTest) {
      await Future<void>.delayed(AppDurations.shimmer);
    }
    emit(state.copyWith(status: LoadStatus.success, revision: state.revision + 1));
  }

  void _place(OrderPlaceRequested event, Emitter<OrderState> emit) {
    AppLogger.log('OrderBloc: OrderPlaceRequested');
    if (event.cart.items.isEmpty) return;
    final first = event.cart.items.first;
    final order = OrderModel(
      id: 'OM-${24020 + state.orders.length}',
      buyerName: 'Al Noor Medical Center',
      supplierName: first.offer.supplierName,
      productName: first.product.name,
      quantity: event.cart.itemCount,
      total: event.cart.total,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      productId: first.product.id,
      offerId: first.offer.id,
    );
    emit(
      state.copyWith(
        orders: [order, ...state.orders],
        placedOrder: order,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    _cart.add(const CartCleared());
  }

  void _buyAgain(OrderBuyAgainRequested event, Emitter<OrderState> emit) {
    AppLogger.log('OrderBloc: OrderBuyAgainRequested');
    final order = event.order;
    var offer = _catalog.getOffers().firstWhereOrNull((item) => item.id == order.offerId);
    var product = _catalog.findProduct(order.productId);
    product ??= _catalog.getProducts().firstWhereOrNull((item) => item.name == order.productName);
    if (offer == null && product != null) {
      final matching = _catalog.getOffers().where((item) => item.productId == product!.id);
      offer = matching.firstWhereOrNull((item) => item.supplierName == order.supplierName);
      offer ??= matching.isEmpty ? null : matching.reduce((a, b) => a.price <= b.price ? a : b);
    }
    if (product == null || offer == null || offer.stock <= 0) {
      emit(
        state.copyWith(
          errorMessage: AppLocale.translate('offer_unavailable'),
          clearPlaced: true,
          revision: state.revision + 1,
        ),
      );
      return;
    }
    final quantity = order.quantity < offer.minimumOrder ? offer.minimumOrder : order.quantity;
    _cart.add(CartItemAdded(product: product, offer: offer, quantity: quantity));
    emit(state.copyWith(errorMessage: '', clearPlaced: true, revision: state.revision + 1));
  }

  void _advance(OrderStatusAdvanced event, Emitter<OrderState> emit) {
    final index = state.orders.indexWhere((order) => order.id == event.id);
    if (index < 0) return;
    final current = state.orders[index];
    if (current.status.index >= OrderStatus.values.length - 1) return;
    final next = [...state.orders];
    next[index] = current.copyWith(status: OrderStatus.values[current.status.index + 1]);
    emit(state.copyWith(orders: next, revision: state.revision + 1));
  }
}
