import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Book {
  final String title;
  final String authors;
  final String thumbnail;
  final String description;
  final String publishedDate;

  Book({
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
    required this.publishedDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    return Book(
      title: volumeInfo['title'] ?? 'Tanpa Judul',
      authors: volumeInfo['authors'] != null
          ? (volumeInfo['authors'] as List).join(', ')
          : 'Penulis tidak tersedia',
      thumbnail: volumeInfo['imageLinks']?['thumbnail'] ?? '',
      description: volumeInfo['description'] ?? 'Deskripsi tidak tersedia',
      publishedDate: volumeInfo['publishedDate'] ?? 'Tanggal tidak tersedia',
    );
  }
}

class GoogleBooksService {
  static const String apiKey = 'api_key';

  static Future<List<Book>> searchBooks(String keyword) async {
    final url = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      {
        'q': keyword,
        'key': apiKey,
        'maxResults': '20',
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'] ?? [];

      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception(
        'Gagal mengambil data buku. Status: ${response.statusCode}',
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Books API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const BookPage(),
    );
  }
}

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final TextEditingController searchController = TextEditingController();
  late Future<List<Book>> books;

  @override
  void initState() {
    super.initState();
    books = GoogleBooksService.searchBooks('flutter');
  }

  void searchBook() {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kata kunci pencarian'),
        ),
      );
      return;
    }

    setState(() {
      books = GoogleBooksService.searchBooks(keyword);
    });
  }

  String secureImageUrl(String url) {
    return url.replaceFirst('http://', 'https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Google Books API'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Cari buku',
                      hintText: 'Contoh: flutter, android, python',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => searchBook(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: searchBook,
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: books,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final bookList = snapshot.data ?? [];

                if (bookList.isEmpty) {
                  return const Center(
                    child: Text('Data buku tidak ditemukan'),
                  );
                }

                return ListView.builder(
                  itemCount: bookList.length,
                  itemBuilder: (context, index) {
                    final book = bookList[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: book.thumbnail.isNotEmpty
                            ? Image.network(
                                secureImageUrl(book.thumbnail),
                                width: 55,
                                height: 75,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.book,
                                size: 50,
                                color: Colors.indigo,
                              ),
                        title: Text(
                          book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Penulis: ${book.authors}\n'
                          'Terbit: ${book.publishedDate}\n\n'
                          '${book.description}',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
