import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/extensions/iterable_x.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/profile/data/models/user_profile.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc(
    this._catalog,
    this._cart,
    this._dio,
    this._auth,
    this._cache,
    this._profile,
  ) : super(OrderState(orders: AppEnv.useRemote ? const [] : _seed)) {
    on<OrderStarted>(_start);
    on<OrderDetailRequested>(_detail);
    on<OrderPlaceRequested>(_place);
    on<OrderBuyAgainRequested>(_buyAgain);
    on<OrderStatusAdvanced>(_advance);
    on<OrderCancelRequested>(_cancel);
    on<OrderFeedbackCleared>(
      (event, emit) => emit(
        state.copyWith(errorMessage: '', revision: state.revision + 1),
      ),
    );
    on<OrderReset>(
      (event, emit) => emit(
        OrderState(
          orders: AppEnv.useRemote ? const [] : _seed,
          revision: state.revision + 1,
        ),
      ),
    );
  }

  static const _query = {'page': 1, 'limit': 50};

  final CatalogRepository _catalog;
  final CartBloc _cart;
  final Dio _dio;
  final AuthBloc _auth;
  final RemoteCache _cache;
  final UserProfile Function() _profile;

  List<OrderModel> get orders => state.orders;

  String get _path => _auth.state.role == UserRole.supplier
      ? ApiEndpoints.supplierOrders
      : ApiEndpoints.buyerOrders;

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
    if (!AppEnv.useRemote) {
      emit(
        state.copyWith(
          status: LoadStatus.success,
          revision: state.revision + 1,
        ),
      );
      return;
    }
    final cached = _parse(_cache.peek(_path, query: _query));
    emit(
      state.copyWith(
        orders: cached.isEmpty ? null : cached,
        status: LoadStatus.loading,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    try {
      final orders = _parse(await _cache.get(_path, query: _query));
      emit(
        state.copyWith(
          orders: orders,
          status: LoadStatus.success,
          revision: state.revision + 1,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: ApiError.message(error),
          revision: state.revision + 1,
        ),
      );
    }
  }

  Future<void> _detail(
    OrderDetailRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (!AppEnv.useRemote || event.id.isEmpty) return;
    try {
      final body = await _cache.get(ApiEndpoints.order(event.id));
      final json = ApiJson.asMap(ApiJson.unwrap(body));
      final order = json == null ? null : OrderModel.tryParse(json);
      if (order == null) return;
      final exists = state.orders.any((item) => item.id == order.id);
      emit(
        state.copyWith(
          orders: exists
              ? [
                  for (final item in state.orders)
                    item.id == order.id ? order : item,
                ]
              : [order, ...state.orders],
          revision: state.revision + 1,
        ),
      );
    } on Object catch (error) {
      AppLogger.log('OrderBloc: detail failed $error');
      if (state.byId(event.id) == null) {
        emit(
          state.copyWith(
            errorMessage: ApiError.message(error),
            revision: state.revision + 1,
          ),
        );
      }
    }
  }

  List<OrderModel> _parse(Object? body) => [
    for (final row in ApiJson.maps(body)) ?OrderModel.tryParse(row),
  ];

  Future<void> _place(
    OrderPlaceRequested event,
    Emitter<OrderState> emit,
  ) async {
    AppLogger.log('OrderBloc: OrderPlaceRequested');
    if (event.cart.items.isEmpty) return;
    final profile = _profile();
    final first = event.cart.items.first;
    final recipient = profile.fullName.isNotEmpty
        ? profile.fullName
        : profile.organization;
    final order = OrderModel(
      id: 'OM-${24020 + state.orders.length}',
      buyerName: profile.organization.isEmpty
          ? 'Al Noor Medical Center'
          : profile.organization,
      supplierName: first.offer.supplierName,
      productName: first.product.name,
      quantity: event.cart.itemCount,
      total: event.cart.total,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      productId: first.product.id,
      offerId: first.offer.id,
    );
    if (!AppEnv.useRemote) {
      emit(
        state.copyWith(
          orders: [order, ...state.orders],
          placedOrder: order,
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
      _cart.add(const CartCleared());
      return;
    }
    final missing = [
      recipient,
      event.phone,
      profile.country,
      profile.city,
      profile.fullAddress,
      profile.postalCode,
    ].any((value) => value.trim().isEmpty);
    if (missing) {
      emit(
        state.copyWith(
          errorMessage: AppLocale.translate('complete_address'),
          revision: state.revision + 1,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        placing: true,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    try {
      await _dio.delete<dynamic>(ApiEndpoints.cart);
      for (final item in event.cart.items) {
        await _dio.post<dynamic>(
          ApiEndpoints.cartItems,
          data: {'productId': item.product.id, 'quantity': item.quantity},
        );
      }
      final response = await _dio.post<dynamic>(
        ApiEndpoints.checkout,
        data: {
          'shippingAddress': {
            'recipientName': recipient,
            'phone': event.phone.trim(),
            'country': profile.country,
            'city': profile.city,
            'fullAddress': profile.fullAddress,
            'postalCode': profile.postalCode,
          },
          'paymentMethod': 'BANK_TRANSFER',
          if (event.notes.trim().isNotEmpty)
            'deliveryNotes': event.notes.trim(),
        },
      );
      final body = ApiJson.unwrap(response.data);
      final created = [
        for (final row in ApiJson.maps(body)) ?OrderModel.tryParse(row),
      ];
      final saved = created.isEmpty ? order : created.first;
      emit(
        state.copyWith(
          orders: [
            ...(created.isEmpty ? [order] : created),
            ...state.orders,
          ],
          placedOrder: saved,
          placing: false,
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
      _cart.add(const CartCleared());
    } on Object catch (error) {
      emit(
        state.copyWith(
          placing: false,
          errorMessage: ApiError.message(error),
          revision: state.revision + 1,
        ),
      );
    }
  }

  void _buyAgain(OrderBuyAgainRequested event, Emitter<OrderState> emit) {
    AppLogger.log('OrderBloc: OrderBuyAgainRequested');
    final order = event.order;
    var offer = _catalog.getOffers().firstWhereOrNull(
      (item) => item.id == order.offerId,
    );
    var product = _catalog.findProduct(order.productId);
    product ??= _catalog.getProducts().firstWhereOrNull(
      (item) => item.name == order.productName,
    );
    if (offer == null && product != null) {
      final matching = _catalog.getOffers().where(
        (item) => item.productId == product!.id,
      );
      offer = matching.firstWhereOrNull(
        (item) => item.supplierName == order.supplierName,
      );
      offer ??= matching.isEmpty
          ? null
          : matching.reduce((a, b) => a.price <= b.price ? a : b);
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
    final quantity = order.quantity < offer.minimumOrder
        ? offer.minimumOrder
        : order.quantity;
    _cart.add(
      CartItemAdded(product: product, offer: offer, quantity: quantity),
    );
    emit(
      state.copyWith(
        errorMessage: '',
        clearPlaced: true,
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _advance(
    OrderStatusAdvanced event,
    Emitter<OrderState> emit,
  ) async {
    final current = state.byId(event.id);
    if (current == null || current.cancelled) return;
    if (current.status == OrderStatus.delivered) return;
    final nextStatus = AppEnv.useRemote
        ? OrderModel.nextRemoteStatus(current.status)
        : OrderStatus.values[current.status.index + 1];
    final tracking = event.trackingNumber.trim();
    final courier = event.courierName.trim();
    await _update(
      emit,
      current,
      {
        'status': OrderModel.statusWireName(nextStatus),
        if (tracking.isNotEmpty) 'trackingNumber': tracking,
        if (courier.isNotEmpty) 'courierName': courier,
      },
      current.copyWith(
        status: nextStatus,
        trackingNumber: tracking.isEmpty ? null : tracking,
        courierName: courier.isEmpty ? null : courier,
      ),
    );
  }

  Future<void> _cancel(
    OrderCancelRequested event,
    Emitter<OrderState> emit,
  ) async {
    final current = state.byId(event.id);
    if (current == null || current.cancelled) return;
    await _update(
      emit,
      current,
      {
        'status': 'CANCELLED',
        if (event.reason.trim().isNotEmpty)
          'cancellationReason': event.reason.trim(),
      },
      current.copyWith(cancelled: true),
    );
  }

  Future<void> _update(
    Emitter<OrderState> emit,
    OrderModel current,
    Map<String, Object?> body,
    OrderModel next,
  ) async {
    emit(
      state.copyWith(
        updatingId: current.id,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.patch<dynamic>(
          ApiEndpoints.orderStatus(current.id),
          data: body,
        );
      } on Object catch (error) {
        emit(
          state.copyWith(
            updatingId: '',
            errorMessage: ApiError.message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        orders: [
          for (final order in state.orders)
            order.id == current.id ? next : order,
        ],
        updatingId: '',
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }
}
