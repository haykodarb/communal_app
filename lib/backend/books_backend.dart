import 'dart:io';
import 'dart:typed_data';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksBackend {
  static Future<Uint8List> getBookCover(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    Uint8List bytes = await client.storage.from('book_covers').download(book.image_path!);

    return bytes;
  }

  static Future<BackendReponse> addBook(Book book, File image) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String imageExtension = image.path.split('.').last;

    final String pathToUpload = '/$userId/$currentTime.$imageExtension';

    // final String? mimeType = lookupMimeType(image.path);
    // if (mimeType != null) {
    //   if (mimeType != 'image/jpeg' && mimeType != 'image/jpg' && mimeType != 'image/png') ;
    // }

    await client.storage.from('book_covers').upload(
          pathToUpload,
          image,
          retryAttempts: 5,
        );

    final Map<String, dynamic> response = await client
        .from('books')
        .insert(
          {
            'title': book.title,
            'author': book.author,
            'publisher': book.publisher,
            'owner': client.auth.currentUser!.id,
            'image_path': pathToUpload,
          },
        )
        .select()
        .single();

    return BackendReponse(
      success: response.isNotEmpty,
      payload: Book(
        title: response['title'],
        author: response['author'],
        publisher: response['publisher'],
        id: response['id'],
        image_path: response['image_path'],
      ),
    );
  }

  static Future<BackendReponse> deleteBook(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> response = await client.from('books').delete().eq('id', book.id).select();

    await client.storage.from('book_covers').remove(
      [book.image_path!],
    );

    return BackendReponse(success: response.isNotEmpty, payload: response);
  }

  static Future<BackendReponse> getAllBooks() async {
    final SupabaseClient client = Supabase.instance.client;

    final List<Map<String, dynamic>> response = await client.from('books').select<List<Map<String, dynamic>>>('*');

    final List<Book> bookList = response
        .map(
          (Map<String, dynamic> element) => Book(
            title: element['title'],
            author: element['author'],
            publisher: element['publisher'],
            id: element['id'],
            image_path: element['image_path'],
          ),
        )
        .toList();

    return BackendReponse(
      success: true,
      payload: bookList,
    );
  }
}
