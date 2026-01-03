import "dart:convert";
import "dart:typed_data";

import "package:cross_file/cross_file.dart";
import "package:flow/services/categories.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";

final Logger _log = Logger("EnyService");

class EnyService {
  static EnyService? _instance;

  String get apiKey {
    return "enyfc38977379e9037c_6dcfc5e4214a7f79bf2f0537791f4cf30cd84d355af6da473458a121d1ed043b";
  }

  factory EnyService() => _instance ??= EnyService._internal();

  EnyService._internal() {
    // Constructor
  }

  Future<String?> processReceipt(XFile file) async {
    try {
      final Stream<Uint8List> stream = file.openRead();
      final int length = await file.length();

      final request = http.MultipartRequest(
        "post",
        Uri.parse("https://eny.gege.mn/api/v1/receipts"),
      );

      http.MediaType? contentType;

      try {
        if (file.mimeType case String mimeType) {
          contentType = http.MediaType.parse(mimeType);
        }
      } catch (e) {
        //
      }

      request.files.add(
        http.MultipartFile(
          "image",
          stream,
          length,
          filename: file.name,
          contentType: contentType,
        ),
      );
      request.fields["categories"] = await CategoriesService().getAll().then(
        (categories) => categories.take(32).map((x) => x.name).join(","),
      );
      request.headers["X-API-KEY"] = apiKey;

      final response = await request.send().then(http.Response.fromStream);
      final decoded = jsonDecode(response.body);

      return decoded["id"];
    } catch (e, stackTrace) {
      _log.severe("Failed to process receipt", e, stackTrace);
      return null;
    }
  }
}
