import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(child: Text(cart.error ?? 'Your cart is empty.'));
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              ...cart.items.map((item) => _CartItem(item: item)),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(
                    '\u00A5${cart.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Confirm Order'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartProduct item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(product: Product.fromCart(item)),
          ),
        ),
        leading: SizedBox(
          width: 56.w,
          child: item.thumbnail.isEmpty
              ? Icon(Icons.shopping_bag_outlined, size: 32.sp)
              : Image.network(item.thumbnail, fit: BoxFit.cover),
        ),
        title: CustomText(
          text: item.title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('\u00A5${item.price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Decrease quantity',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => context.read<CartProvider>().updateQuantity(
                item.id,
                item.quantity - 1,
              ),
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: 'Increase quantity',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => context.read<CartProvider>().updateQuantity(
                item.id,
                item.quantity + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
