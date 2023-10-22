import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> userData = [];
  Dio dio = Dio();
  String url = 'https://631d6133789612cd07a9ce1d.mockapi.io/users';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          userData = List<Map<String, dynamic>>.from(response.data);
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
          title: Text('Data Pengguna CRUD'),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 200,
              child: userData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: userData.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData[index]['avatar']),
                          ),
                          title: Text(userData[index]['name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  updateUserData(userData[index]);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteUserData(userData[index]['id']);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextFormField(
                      controller: avatarController,
                      decoration: InputDecoration(labelText: 'Avatar URL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addUser();
                      },
                      child: Text('Add User'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateUserData(Map<String, dynamic> user) async {
    String userId = user['id'];
    String updateUrl = '$url/$userId';

    // Create controllers for the input fields
    TextEditingController nameInputController =
        TextEditingController(text: user['name']);
    TextEditingController avatarInputController =
        TextEditingController(text: user['avatar']);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update User Data'),
          content: Column(
            children: <Widget>[
              TextFormField(
                controller: nameInputController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: avatarInputController,
                decoration: InputDecoration(labelText: 'Avatar URL'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Perform the update with the new data
                updateUser(userId, nameInputController.text,
                    avatarInputController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateUser(String userId, String newName, String newAvatar) async {
    String updateUrl = '$url/$userId';

    try {
      Response response = await dio.put(updateUrl, data: {
        'name': newName,
        'avatar': newAvatar,
      });

      if (response.statusCode == 200) {
        print('User updated successfully');
        fetchData(); // Refresh the user list after updating
      } else {
        print('Failed to update user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  void deleteUserData(String userId) async {
    String deleteUrl = '$url/$userId';

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

  void addUser() async {
    try {
      Response response = await dio.post(url, data: {
        'name': nameController.text,
        'avatar': avatarController.text,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      if (response.statusCode == 201) {
        print('User added successfully');
        fetchData(); // Refresh the user list after adding a new user
        nameController.clear();
        avatarController.clear();
      } else {
        print('Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }
}
