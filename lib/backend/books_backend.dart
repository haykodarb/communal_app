import 'dart:io';
import 'dart:typed_data';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksBackend {
  static Future<Uint8List> getBookCover(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    Uint8List bytes = await client.storage.from('book_covers').download(book.image_path);

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
        .select('*, profiles(*)')
        .single();

    return BackendResponse(
      success: response.isNotEmpty,
      payload: response.isNotEmpty ? Book.fromMap(response) : 'Could not create book. Please try again.',
    );
  }

  static Future<BackendResponse> deleteBook(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> response = await client.from('books').delete().eq('id', book.id).select();

    await client.storage.from('book_covers').remove(
      [book.image_path],
    );

    return BackendResponse(success: response.isNotEmpty, payload: response);
  }

  static Future<BackendResponse> getAllBooksForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<Map<String, dynamic>> response =
        await client.from('books').select<List<Map<String, dynamic>>>('*, profiles(*)').eq('owner', userId);

    final List<Book> bookList = response
        .map(
          (Map<String, dynamic> element) => Book.fromMap(element),
        )
        .toList();

    return BackendResponse(
      success: true,
      payload: bookList,
    );
  }

  static Future<BackendResponse> getBooksInCommunity(Community community, int index) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final List<dynamic> membershipResponse = await client.from('memberships').select().match(
      {
        'community': community.id,
        'accepted': true,
      },
    ).neq(
      'member',
      userId,
    );

    final List<String> listOfUserIDs = membershipResponse.map(
      (element) {
        return element['member'] as String;
      },
    ).toList();

    final List<dynamic> booksResponse = await client
        .from('books')
        .select(
          '*, profiles(*)',
        )
        .in_('owner', listOfUserIDs)
        .order('id')
        .range(
          index * 10,
          index * 10 + 10,
        );

    final List<Book> listOfBooks = booksResponse
        .map(
          (element) => Book.fromMap(element),
        )
        .toList();

    return BackendResponse(
      success: listOfBooks.isNotEmpty,
      payload: listOfBooks,
    );
  }
}
