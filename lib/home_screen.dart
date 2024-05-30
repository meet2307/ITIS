import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String userRole; // User role passed to check permissions
  HomeScreen({required this.userRole});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    var response = await http.get(Uri.parse('http://localhost:5000/books'));
    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body)['books'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch books')));
    }
  }

  Future<void> _downloadBook(int bookId) async {
    if (widget.userRole != 'student') { // Assume only 'admin' can download
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You do not have permission to download books')));
      return;
    }
    var response = await http.get(Uri.parse('http://localhost:5000/download/$bookId'));
    if (response.statusCode == 200) {
      // Process the download
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download started...')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download book')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library Home"),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]['title']),
            subtitle: Text('Book ID: ${books[index]['id']}'),
            trailing: IconButton(
              icon: Icon(Icons.download),
              onPressed: () => _downloadBook(books[index]['id']),
            ),
          );
        },
      ),
    );
  }
}
