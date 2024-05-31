import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itis_project_python/login_screen.dart';
import 'package:itis_project_python/session_manager.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final String userRole; // User role passed to check permissions
  HomeScreen({required this.userRole});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    searchController.addListener(_filterBooks);
  }

  Future<List<dynamic>> _fetchBooks() async {
    try {
      var response = await http.get(Uri.parse('http://localhost:5000/books'));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          books = jsonResponse['books'];
          filteredBooks = books;
        });
        return books;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch books')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching books: $e')));
    }
    return []; // Return an empty list on error
  }

  void _filterBooks() {
    String searchTerm = searchController.text;
    if (searchTerm.isEmpty) {
      setState(() {
        filteredBooks = books;
      });
    } else {
      setState(() {
        filteredBooks = books.where((book) =>
            book['title'].toString().toLowerCase().contains(searchTerm.toLowerCase())).toList();
      });
    }
  }

  Future<void> _downloadBook(int bookId) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission is needed to download files')));
      return;
    }

    final uri = Uri.parse('http://localhost:5000/download/$bookId');
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = new File('$dir/book-$bookId.pdf');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download completed and saved to $dir')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download book')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading book: $e')));
    }
  }

  void _logout() {
    SessionManager().logout().then((_) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library Home"),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Books',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                sortColumnIndex: 0,
                columns: [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Book ID')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filteredBooks.map<DataRow>((book) => DataRow(
                  cells: [
                    DataCell(Text(book['title'])),
                    DataCell(Text(book['id'].toString())),
                    DataCell(IconButton(
                      icon: Icon(Icons.download, color: Colors.blue),
                      onPressed: () => _downloadBook(book['id']),
                    )),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
