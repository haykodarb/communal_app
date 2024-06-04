import 'dart:convert';
import 'dart:io';
import 'package:communal/models/backend_response.dart';
import 'package:cronet_http/cronet_http.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

class OpenLibraryBook {
  String code;
  String? title;
  String? author;

  OpenLibraryBook(this.code);
}

class OpenLibraryBackend {
  static const String isbnURL = "https://openlibrary.org/isbn";

  static Future<File?> getCoverByISBN(String isbnCode) async {
    try {
      final Client http;

      if (Platform.isAndroid) {
        final engine =
            CronetEngine.build(cacheMode: CacheMode.memory, cacheMaxSize: 2 * 1024 * 1024, userAgent: 'Book Agent');
        http = CronetClient.fromCronetEngine(engine, closeEngine: true);
      } else {
        http = IOClient(HttpClient()..userAgent = 'Book Agent');
      }

      Uri coverUri = Uri.https("covers.openlibrary.org", "/b/isbn/$isbnCode-L.jpg");

      Response response = await http.get(coverUri);

      if (response.statusCode >= 300) throw ('');

      final String tempPath = (await getTemporaryDirectory()).path;

      image.Image? originalImage = image.decodeJpg(response.bodyBytes);

      if (originalImage == null) throw '';

      double red = 0;
      double green = 0;
      double blue = 0;
      double count = 0;

      for (int x = 0; x < originalImage.width; x++) {
        for (int y = 0; y < originalImage.height; y++) {
          image.Pixel pixel = originalImage.getPixel(x, y);
          red = red + pixel.r;
          green = green + pixel.g;
          blue = blue + pixel.b;
          count = count + 1;
        }
      }
      int redAvg = red ~/ count;
      int greenAvg = green ~/ count;
      int blueAvg = blue ~/ count;

      image.Image expandedImage = image.copyExpandCanvas(
        originalImage,
        newHeight: originalImage.height > (originalImage.width * (4 / 3))
            ? originalImage.height
            : (originalImage.width * 4) ~/ 3,
        newWidth: originalImage.width > (originalImage.height * (3 / 4))
            ? originalImage.width
            : (originalImage.height * 3) ~/ 4,
        position: image.ExpandCanvasPosition.bottomCenter,
        backgroundColor: image.ColorRgb8(redAvg, greenAvg, blueAvg),
      );

      File expandedFile = File('$tempPath/expanded.jpg');
      expandedFile.writeAsBytesSync(image.encodeJpg(expandedImage));

      http.close();

      return File(expandedFile.path);
    } catch (e) {
      return null;
    }
  }

  static Future<BackendResponse> getBookByISBN(String isbnCode) async {
    try {
      final Client http;

      if (Platform.isAndroid) {
        final engine =
            CronetEngine.build(cacheMode: CacheMode.memory, cacheMaxSize: 2 * 1024 * 1024, userAgent: 'Book Agent');
        http = CronetClient.fromCronetEngine(engine, closeEngine: true);
      } else {
        http = IOClient(HttpClient()..userAgent = 'Book Agent');
      }

      OpenLibraryBook book = OpenLibraryBook(isbnCode);

      Uri bookUri = Uri.https(
        "openlibrary.org",
        "/isbn/${book.code}.json",
      );

      Response bookResponse = await http.get(bookUri);

      if (bookResponse.statusCode >= 300) {
        http.close();
        return BackendResponse(success: false, payload: "Could not find book in OpenLibrary database");
      }

      Map<String, dynamic> bookMap = jsonDecode(bookResponse.body);

      book.title = bookMap['title'];

      String authorCode = bookMap['authors']![0]['key'];

      Uri authorUri = Uri.https("openlibrary.org", "$authorCode.json");

      Response authorResponse = await http.get(authorUri);

      if (authorResponse.statusCode == 200) {
        Map<String, dynamic> authorMap = jsonDecode(authorResponse.body);

        book.author = authorMap['name'];
      }

      http.close();
      return BackendResponse(success: true, payload: book);
    } catch (e) {
      return BackendResponse(success: false, payload: e);
    }
  }
}
