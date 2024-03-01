import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll/models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  int totalProducts = 1000;
  final ScrollController _scrollController = ScrollController();

  final Dio _dio = Dio();

  bool isLoading = false;

  Future<void> fetchProducts() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await _dio.get(
        'https://dummyjson.com/products?limit=15&skip=${products.length}&select=title,price,thumbnail',
      );

      final List data = response.data['products'];
      print(data);
      final List<Product> fetchedProducts = data
          .map((dynamic json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        isLoading = false;
        totalProducts = response.data['total'];
        products.addAll(fetchedProducts);
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch products'),
        ),
      );
    }
  }

  void loadMoreProducts() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        products.length < totalProducts) {
      fetchProducts();
    }
  }

  @override
  void initState() {
    fetchProducts();

    _scrollController.addListener(() {
      loadMoreProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: false,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: ((context, index) {
            return Column(
              children: [
                ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(products[index].title),
                  subtitle: Text('\$${products[index].price}'),
                  trailing: ClipRRect(
                      child: Image.network(
                    products[index].thumbnail,
                    fit: BoxFit.cover,
                  )),
                ),
                if (index == products.length - 1 && isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CupertinoActivityIndicator(),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
