import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itis_project_python/login_screen.dart';
import 'package:itis_project_python/session_manager.dart';
import 'dart:convert';
import 'dart:html' as html;

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
  PlatformFile? selectedFile;

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

  // Future<void> _downloadBook(int bookId) async {
  //   print(bookId);
  //   if (widget.userRole != 'student') { // Assume only 'admin' can download
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('You do not have permission to download books')));
  //     return;
  //   }
  //   var response = await http.get(
  //       Uri.parse('http://localhost:5000/download/$bookId'));
  //   if (response.statusCode == 200) {
  //     // Process the download
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Download started...')));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to download book')));
  //   }
  // }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  Future<void> _downloadBook(int bookId, String bookTitle) async {
    String sanitizedTitle = _sanitizeFileName(bookTitle);

    var response = await http.get(Uri.parse('http://localhost:5000/download/$bookId'));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$sanitizedTitle.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded book successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download book')),
      );
    }
  }

  Future<void> _deleteBook(int bookId) async {
    var response = await http.delete(
      Uri.parse('http://localhost:5000/delete_book/$bookId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book deleted successfully')));
      _fetchBooks(); // Refresh the book list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete book')));
    }
  }

  Future<void> _insertBook() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
      return;
    }

    try {
      String base64File = base64Encode(selectedFile!.bytes!);
      var response = await http.post(
        Uri.parse('http://localhost:5000/add_book'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': selectedFile!.name,
          'file_data': base64File,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book added successfully')));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(userRole: 'admin')),
          //MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add book: ${response.statusCode}')));
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        selectedFile = result.files.first;
        _insertBook();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File selection cancelled')));
      }
    } catch (e) {
      print('Error occurred during file selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred during file selection: $e')));
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
          if (widget.userRole == 'admin')
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _pickFile,
                child: Text('Add Books'),
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
                  DataColumn(label: Text('Download')),
                  if(widget.userRole=='admin')
                    DataColumn(label: Text('Delete')),
                ],
                rows: filteredBooks.map<DataRow>((book) => DataRow(
                  cells: [
                    DataCell(Text(book['title'])),
                    DataCell(Text(book['id'].toString())),
                    DataCell(IconButton(
                      icon: Icon(Icons.download, color: Colors.blue),
                      onPressed: () => _downloadBook(book['id'], book['title']),
                    )),
                    if(widget.userRole=='admin')
                      DataCell(IconButton(
                        icon: Icon(Icons.delete, color: Colors.blue),
                        onPressed: () => _deleteBook(book['id']),
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
