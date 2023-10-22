import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> userData = [];
  String url = 'https://631d6133789612cd07a9ce1d.mockapi.io/users';
  Dio dio = Dio();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      //logic pemanggilan jika berhasil
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          userData = List<Map<String, dynamic>>.from(response.data);
          print(userData);
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
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Data Pengguna'),
      ),
      body: userData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userData.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(userData[index]['avatar'])),
                    title: Text(userData[index]['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            //logic untuk menghapus ada di disini
                            deleteUserData(userData[index]['id']);
                          },
                        ),
                      ],
                    ));
              }),
    ));
  }

  Future<void> deleteUserData(userData) async {
    String deleteUrl = '$url/$userData';
    print('delte user');
    try {
      Response response = await dio.delete(deleteUrl);
      if (response.statusCode == 200) {
        print('User deleted successfully');
        // Refresh the user list after deletion
        fetchData();
      } else {
        print('Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }
}
