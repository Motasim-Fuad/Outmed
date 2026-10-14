import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/features/cart/domain/cart_item.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_add);
    on<CartQuantityChanged>(_quantity);
    on<CartCleared>(_clear);
  }

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
      next[index] = next[index].copyWith(quantity: next[index].quantity + event.quantity);
    } else {
      next.add(
        CartItem(product: event.product, offer: event.offer, quantity: event.quantity),
      );
    }
    emit(state.copyWith(items: next, revision: state.revision + 1));
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
  }

  void _clear(CartCleared event, Emitter<CartState> emit) {
    emit(state.copyWith(items: const [], revision: state.revision + 1));
  }
}
