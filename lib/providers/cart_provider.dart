import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService;
  final List<CartProduct> _items = [];
  bool _hasLoaded = false;
  String? _error;

  CartProvider({CartService? cartService})
    : _cartService = cartService ?? CartService();

  List<CartProduct> get items => List.unmodifiable(_items);
  String? get error => _error;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  Future<void> loadCart() async {
    if (_hasLoaded) return;
    _error = null;
    _items.clear();
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _hasLoaded = true;
    _error = null;
    try {
      await _cartService.addToCart(
        userId: 1,
        productId: product.id,
        quantity: 1,
      );
    } catch (error) {
      _error = 'Unable to sync with the cart API.';
    }

    final index = _items.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      _items.add(
        CartProduct(
          id: product.id,
          title: product.title,
          price: product.price,
          quantity: 1,
          total: product.price,
          discountPercentage: product.discountPercentage,
          discountedTotal: product.price,
          thumbnail: product.thumbnail,
        ),
      );
    } else {
      final item = _items[index];
      _items[index] = CartProduct(
        id: item.id,
        title: item.title,
        price: item.price,
        quantity: item.quantity + 1,
        total: item.price * (item.quantity + 1),
        discountPercentage: item.discountPercentage,
        discountedTotal: item.price * (item.quantity + 1),
        thumbnail: item.thumbnail,
      );
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index == -1) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      final item = _items[index];
      _items[index] = CartProduct(
        id: item.id,
        title: item.title,
        price: item.price,
        quantity: quantity,
        total: item.price * quantity,
        discountPercentage: item.discountPercentage,
        discountedTotal: item.price * quantity,
        thumbnail: item.thumbnail,
      );
    }
    notifyListeners();
  }
}
