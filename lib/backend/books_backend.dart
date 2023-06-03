import 'dart:io';
import 'dart:typed_data';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksBackend {
  static Future<Uint8List> getBookCover(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    Uint8List bytes = await client.storage.from('book_covers').download(book.image_path!);

    return bytes;
  }

  static Future<BackendResponse> addBook(Book book, File image) async {
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
            'owner': client.auth.currentUser!.id,
            'image_path': pathToUpload,
          },
        )
        .select()
        .single();

    return BackendResponse(
      success: response.isNotEmpty,
      payload: Book(
        title: response['title'],
        author: response['author'],
        id: response['id'],
        image_path: response['image_path'],
      ),
    );
  }

  static Future<BackendResponse> deleteBook(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> response = await client.from('books').delete().eq('id', book.id).select();

    await client.storage.from('book_covers').remove(
      [book.image_path!],
    );

    return BackendResponse(success: response.isNotEmpty, payload: response);
  }

  static Future<BackendResponse> getAllBooks() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<Map<String, dynamic>> response =
        await client.from('books').select<List<Map<String, dynamic>>>().eq('owner', userId);

    final List<Book> bookList = response
        .map(
          (Map<String, dynamic> element) => Book(
            title: element['title'],
            author: element['author'],
            id: element['id'],
            image_path: element['image_path'],
          ),
        )
        .toList();

    return BackendResponse(
      success: true,
      payload: bookList,
    );
  }

  static Future<BackendResponse> getBooksInCommunity(Community community, int index) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> membershipResponse = await client.from('memberships').select().eq('community', community.id);

    final List<String> listOfUserIDs = membershipResponse.map(
      (element) {
        return element['member'] as String;
      },
    ).toList();

    listOfUserIDs.remove(client.auth.currentUser!.id);

    final List<dynamic> booksResponse = await client
        .from('books')
        .select('id, title, author, image_path, profiles(id, username)')
        .in_('owner', listOfUserIDs)
        .order('id')
        .range(
          index * 10,
          index * 10 + 10,
        );

    final List<Book> listOfBooks = booksResponse
        .map(
          (e) => Book(
            id: e['id'],
            title: e['title'],
            author: e['author'],
            image_path: e['image_path'],
            ownerName: e['profiles']['username'],
            ownerId: e['profiles']['id'],
          ),
        )
        .toList();

    return BackendResponse(
      success: listOfBooks.isNotEmpty,
      payload: listOfBooks,
    );
  }
}
