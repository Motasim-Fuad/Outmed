import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/features/cart/domain/cart_item.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_state.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc([this._cache, this._queue]) : super(const CartState()) {
    on<CartItemAdded>(_add);
    on<CartQuantityChanged>(_quantity);
    on<CartCleared>(_clear);
    on<CartSyncRequested>(_sync);
  }

  final RemoteCache? _cache;
  final OfflineQueue? _queue;
  Timer? _push;

  List<CartItem> get items => state.items;
  double get subtotal => state.subtotal;
  double get vat => state.vat;
  double get deliveryFee => state.deliveryFee;
  double get total => state.total;
  int get itemCount => state.itemCount;

  void _add(CartItemAdded event, Emitter<CartState> emit) {
    AppLogger.log('CartBloc: CartItemAdded');
    final next = [...state.items];
    final index = next.indexWhere((item) => item.offer.id == event.offer.id);
    if (index >= 0) {
      next[index] = next[index].copyWith(
        quantity: next[index].quantity + event.quantity,
      );
    } else {
      next.add(
        CartItem(
          product: event.product,
          offer: event.offer,
          quantity: event.quantity,
        ),
      );
    }
    emit(state.copyWith(items: next, revision: state.revision + 1));
    _schedulePush();
  }

  void _quantity(CartQuantityChanged event, Emitter<CartState> emit) {
    final next = [...state.items];
    final index = next.indexWhere((item) => item.offer.id == event.offerId);
    if (index < 0) return;
    final quantity = next[index].quantity + event.delta;
    if (quantity <= 0) {
      next.removeAt(index);
    } else {
      next[index] = next[index].copyWith(quantity: quantity);
    }
    emit(state.copyWith(items: next, revision: state.revision + 1));
    _schedulePush();
  }

  void _clear(CartCleared event, Emitter<CartState> emit) {
    _push?.cancel();
    emit(state.copyWith(items: const [], revision: state.revision + 1));
  }

  Future<void> _sync(CartSyncRequested event, Emitter<CartState> emit) async {
    final cache = _cache;
    if (cache == null || !AppEnv.useRemote || state.items.isNotEmpty) return;
    try {
      final items = _parse(await cache.get(ApiEndpoints.cart));
      if (items.isEmpty || state.items.isNotEmpty) return;
      emit(state.copyWith(items: items, revision: state.revision + 1));
    } on Object catch (error) {
      AppLogger.log('CartBloc: sync failed $error');
    }
  }

  List<CartItem> _parse(Object? body) {
    final root = ApiJson.asMap(ApiJson.unwrap(body));
    final rows = root == null
        ? ApiJson.maps(body)
        : ApiJson.maps(root['items']);
    final items = <CartItem>[];
    for (final row in rows) {
      final productRow = ApiJson.asMap(row['product']) ?? row;
      final product = ProductModel.tryParse(productRow);
      if (product == null) continue;
      final offer = SupplierOfferModel.fromProductRow(productRow, product);
      if (offer == null) continue;
      final quantity = ApiJson.integer(row, const ['quantity']) ?? 1;
      items.add(CartItem(product: product, offer: offer, quantity: quantity));
    }
    return items;
  }

  void _schedulePush() {
    final queue = _queue;
    if (queue == null || !AppEnv.useRemote) return;
    _push?.cancel();
    _push = Timer(const Duration(seconds: 2), () => unawaited(_pushNow(queue)));
  }

  Future<void> _pushNow(OfflineQueue queue) async {
    final snapshot = [...state.items];
    try {
      await queue.send('DELETE', ApiEndpoints.cart);
      for (final item in snapshot) {
        await queue.send(
          'POST',
          ApiEndpoints.cartItems,
          body: {'productId': item.product.id, 'quantity': item.quantity},
        );
      }
    } on Object catch (error) {
      AppLogger.log('CartBloc: push failed $error');
    }
  }

  @override
  Future<void> close() {
    _push?.cancel();
    return super.close();
  }
}
