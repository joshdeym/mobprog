import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.brand,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 300.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey[300],
                ),
                child: product.thumbnail.isEmpty
                    ? Icon(Icons.image, size: 100.sp, color: Colors.grey[600])
                    : Image.network(
                        product.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image,
                          size: 100.sp,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
              SizedBox(height: 20.h),

              // Product Title
              CustomText(
                text: product.title,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),

              // Rating and Stock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, size: 18.sp, color: Colors.amber),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: product.rating.toString(),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomText(
                      text: 'Stock: ${product.stock}',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Price Section
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: 'Price',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: '\u00A5${product.price.toStringAsFixed(2)}',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        if (product.discountPercentage > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomText(
                              text:
                                  '-${product.discountPercentage.toStringAsFixed(0)}%',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Description Section
              CustomText(
                text: 'Description',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: product.description,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 24.h),

              // Details Section
              CustomText(
                text: 'Details',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              _detailRow('Category', product.category),
              _detailRow('Brand', product.brand),
              _detailRow('SKU', product.sku),
              _detailRow('Weight', '${product.weight}kg'),
              _detailRow('Warranty', product.warrantyInformation),
              _detailRow('Status', product.availabilityStatus),
              SizedBox(height: 24.h),

              // Shipping Section
              CustomText(
                text: 'Shipping Info',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              _detailRow('Shipping', product.shippingInformation),
              _detailRow('Return Policy', product.returnPolicy),
              SizedBox(height: 24.h),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    await context.read<CartProvider>().addProduct(product);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: CustomText(
                          text: '${product.title} added to cart!',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: CustomText(
                    text: 'Add to Cart',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5AF8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: CustomText(
                          text: 'Chat started for ${product.title}',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: CustomText(
                    text: 'Message',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: label,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            Expanded(
              child: CustomText(
                text: value,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
