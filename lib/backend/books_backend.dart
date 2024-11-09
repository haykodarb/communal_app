import 'dart:io';
import 'dart:typed_data';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksQuery {
  String order_by = 'created_at';
  bool? loaned;
  String? search_query;
  int current_index = 0;

  BooksQuery();
}

class BooksBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Uint8List> getBookCover(Book book) async {
    FileInfo? file =
        await DefaultCacheManager().getFileFromCache(book.image_path);

    Uint8List bytes;

    if (file != null) {
      bytes = await file.file.openRead().toBytes();
    } else {
      bytes =
          await _client.storage.from('book_covers').download(book.image_path);

      await DefaultCacheManager()
          .putFile(book.image_path, bytes, key: book.image_path);
    }

    return bytes;
  }

  static Future<BackendResponse> updateBook(Book book, Uint8List? image) async {
    try {
      final String userId = _client.auth.currentUser!.id;
      final String currentTime =
          DateTime.now().millisecondsSinceEpoch.toString();

      String fileName;

      if (image != null) {
        const String imageExtension = 'png';

        fileName = '/$userId/$currentTime.$imageExtension';

        await _client.storage.from('book_covers').uploadBinary(
              fileName,
              image,
              retryAttempts: 5,
            );
      } else {
        fileName = book.image_path;
      }

      final Map<String, dynamic> response = await _client
          .from('books')
          .update(
            {
              'title': book.title,
              'author': book.author,
              'image_path': fileName,
              'public': book.public,
              'review': book.review,
            },
          )
          .eq('id', book.id)
          .select('*, profiles(*)')
          .single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response.isNotEmpty
            ? Book.fromMap(response)
            : 'Could not update book. Please try again.',
      );
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static Future<BackendResponse> addBook(
    Book book,
    Uint8List imageBytes,
  ) async {
    try {
      final String userId = _client.auth.currentUser!.id;
      final String currentTime =
          DateTime.now().millisecondsSinceEpoch.toString();
      const String imageExtension = 'png';

      final String pathToUpload = '/$userId/$currentTime.$imageExtension';

      await _client.storage.from('book_covers').uploadBinary(
            pathToUpload,
            imageBytes,
            retryAttempts: 5,
          );

      final Map<String, dynamic> response = await _client
          .from('books')
          .insert(
            {
              'title': book.title,
              'author': book.author,
              'owner': _client.auth.currentUser!.id,
              'image_path': pathToUpload,
              'public': book.public,
              'review': book.review,
            },
          )
          .select('*, profiles(*)')
          .single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response.isNotEmpty
            ? Book.fromMap(response)
            : 'Could not create book. Please try again.',
      );
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> deleteBook(Book book) async {
    try {
      final List<dynamic> response =
          await _client.from('books').delete().eq('id', book.id).select();

      if (response.isNotEmpty) {
        _client.storage.from('book_covers').remove(
          [book.image_path],
        );
      }

      return BackendResponse(success: response.isNotEmpty, payload: response);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> searchOwnerBooksByQuery(String query) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final List<Map<String, dynamic>> response = await _client
          .from('books')
          .select('*, profiles(*)')
          .or('title.ilike.%$query%, author.ilike.%$query%')
          .eq('owner', userId)
          .limit(10)
          .order('created_at');

      final List<Book> bookList = response
          .map(
            (Map<String, dynamic> element) => Book.fromMap(element),
          )
          .toList();

      return BackendResponse(
        success: true,
        payload: bookList,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getAllBooksForUser({
    String? userToQuery,
    BooksQuery? query,
  }) async {
    try {
      String userId = userToQuery ?? UsersBackend.currentUserId;

      PostgrestFilterBuilder filter =
          _client.from('books').select('*, profiles(*)').eq('owner', userId);

      PostgrestTransformBuilder transform;

      if (query != null) {
        if (query.search_query != null) {
          filter = filter.or(
              'title.ilike.%${query.search_query}%, author.ilike.%${query.search_query}%');
        }

        if (query.loaned != null) {
          filter = filter.eq('loaned', query.loaned!);
        }

        transform = filter.order(query.order_by,
            ascending: query.order_by == 'created_at' ? false : true);
      } else {
        transform = filter.order('created_at');
      }

      final List<Map<String, dynamic>> response = await transform;

      final List<Book> bookList = response
          .map(
            (Map<String, dynamic> element) => Book.fromMap(element),
          )
          .toList();

      return BackendResponse(
        success: true,
        payload: bookList,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getBookById(String id) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('books')
          .select('*, profiles(*)')
          .eq('id', id)
          .maybeSingle();

      return BackendResponse(
        success: response != null,
        payload: response != null ? Book.fromMap(response) : null,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getBooksInCommunity(
    String communityId,
    int index,
    String query,
  ) async {
    try {
      final List<dynamic> booksResponse = await _client
          .rpc(
            'get_books_community',
            params: {
              'community_id': communityId,
              'offset_num': index,
              'limit_num': 10,
              'search_query': query,
            },
          )
          .select('*, profiles(*)')
          .limit(10)
          .order('created_at');

      final List<Book> listOfBooks = booksResponse
          .map(
            (element) => Book.fromMap(element),
          )
          .toList();

      return BackendResponse(
        success: true,
        payload: listOfBooks,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }
}
