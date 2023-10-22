import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    Dio dio = Dio();
    String url = 'https://631d6133789612cd07a9ce1d.mockapi.io/users/1/products';

    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          productList = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Gagal mengambil data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Produk'),
      ),
      body: productList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(productList[index]['image']),
                  title: Text(productList[index]['productName']),
                  subtitle: Text('Harga: \$${productList[index]['price']}'),
                  isThreeLine: true,
                  dense: true,
                );
              },
            ),
    );
  }
}
