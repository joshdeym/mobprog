import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// models
import '../models/product.dart';
import '../providers/cart_provider.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  // Sample sneaker data
  List<Product> _getSneakerProducts() {
    return [
      Product(
        id: 1,
        title: 'Nike Air Max 90',
        description: 'Classic Nike Air Max 90 sneaker in white and black',
        category: 'Sneakers',
        price: 119.99,
        discountPercentage: 10.0,
        rating: 4.5,
        stock: 50,
        tags: ['shoes', 'sneakers', 'nike'],
        brand: 'Nike',
        sku: 'NIKE-AM90-001',
        weight: 0.4,
        dimensions: ProductDimensions(width: 30, height: 15, depth: 15),
        warrantyInformation: '1 Year Warranty',
        shippingInformation: 'Ships within 3-5 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return policy',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: 'NIKE001',
          qrCode: 'QR001',
        ),
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
      ),
      Product(
        id: 2,
        title: 'Nike React Infinity Run',
        description: 'Premium Nike React running shoe with cushioning',
        category: 'Sneakers',
        price: 159.99,
        discountPercentage: 15.0,
        rating: 4.7,
        stock: 40,
        tags: ['shoes', 'sneakers', 'running', 'nike'],
        brand: 'Nike',
        sku: 'NIKE-REACT-001',
        weight: 0.35,
        dimensions: ProductDimensions(width: 30, height: 15, depth: 15),
        warrantyInformation: '1 Year Warranty',
        shippingInformation: 'Ships within 3-5 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return policy',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: 'NIKE002',
          qrCode: 'QR002',
        ),
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800&q=80',
      ),
      Product(
        id: 3,
        title: 'Jordan 1 Retro High',
        description: 'Iconic Air Jordan 1 Retro in classic black and red',
        category: 'Sneakers',
        price: 189.99,
        discountPercentage: 5.0,
        rating: 4.8,
        stock: 30,
        tags: ['shoes', 'sneakers', 'jordan', 'basketball'],
        brand: 'Jordan',
        sku: 'JORDAN-1-001',
        weight: 0.45,
        dimensions: ProductDimensions(width: 30, height: 15, depth: 15),
        warrantyInformation: '1 Year Warranty',
        shippingInformation: 'Ships within 3-5 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return policy',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: 'JORDAN001',
          qrCode: 'QR003',
        ),
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&q=80',
      ),
      Product(
        id: 4,
        title: 'Jordan 11 Space Jam',
        description: 'Air Jordan 11 in Space Jam colorway',
        category: 'Sneakers',
        price: 225.00,
        discountPercentage: 0.0,
        rating: 4.9,
        stock: 20,
        tags: ['shoes', 'sneakers', 'jordan', 'limited'],
        brand: 'Jordan',
        sku: 'JORDAN-11-001',
        weight: 0.45,
        dimensions: ProductDimensions(width: 30, height: 15, depth: 15),
        warrantyInformation: '1 Year Warranty',
        shippingInformation: 'Ships within 3-5 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return policy',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: 'JORDAN002',
          qrCode: 'QR004',
        ),
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800&q=80',
      ),
      Product(
        id: 5,
        title: 'Adidas Ultraboost 22',
        description: 'Advanced Adidas Ultraboost with Boost cushioning',
        category: 'Sneakers',
        price: 180.00,
        discountPercentage: 20.0,
        rating: 4.6,
        stock: 45,
        tags: ['shoes', 'sneakers', 'adidas', 'running'],
        brand: 'Adidas',
        sku: 'ADIDAS-UB22-001',
        weight: 0.38,
        dimensions: ProductDimensions(width: 30, height: 15, depth: 15),
        warrantyInformation: '1 Year Warranty',
        shippingInformation: 'Ships within 3-5 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return policy',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: 'ADIDAS001',
          qrCode: 'QR005',
        ),
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&q=80',
      ),
      Product(
        id: 6,
        title: 'Adidas NMD R1',
        description: 'Classic Adidas NMD R1 in white colorway',
        category: 'Sneakers',
        price: 129.99,
        discountPercentage: 12.0,
        rating: 4.4,
        stock: 55,
        tags: ['shoes', 'sneakers', 'adidas', 'lifestyle'],
        brand: 'Adidas',
        sku: 'ADIDAS-NMD-001',
        weight: 0.36,
        dimensions: ProductDimensions(width: 30, height: 15, depth: 15),
        warrantyInformation: '1 Year Warranty',
        shippingInformation: 'Ships within 3-5 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return policy',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: 'ADIDAS002',
          qrCode: 'QR006',
        ),
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=800&q=80',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = Future.value(_getSneakerProducts()).then((products) {
      _allProducts = products;
      _filteredProducts = products;
      return products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where(
              (product) =>
                  product.title.toLowerCase().contains(query.toLowerCase()) ||
                  product.brand.toLowerCase().contains(query.toLowerCase()) ||
                  product.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Premium Sneakers',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text:
                  'Explore our collection of Nike, Jordan, and Adidas sneakers',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            SizedBox(height: 16.h),
            Container(
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(),
              ),
              child: TextField(
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: 'Search by brand or model...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 20.h),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(100.r),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 16.sp,
                    ),
                  );
                }

                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: 'No products found.',
                      fontSize: 16.sp,
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image, size: 50.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.brand,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomText(
                                          text:
                                              '\u00A5${product.price.toStringAsFixed(2)}',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 12.sp,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 2.w),
                                          CustomText(
                                            text: product.rating
                                                .toStringAsFixed(1),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        tooltip: 'Add to cart',
                                        icon: Icon(
                                          Icons.add_shopping_cart,
                                          size: 18.sp,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () async {
                                          await context
                                              .read<CartProvider>()
                                              .addProduct(product);
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product.title} added to cart',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
