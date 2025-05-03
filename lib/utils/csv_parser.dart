import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:charset/charset.dart";
import "package:csv/csv.dart";
import "package:flow/utils/line_break_normalizer.dart";

Future<List<List>> parseCsvFromFile(File file) async {
  final Uint8List bytes = file.readAsBytesSync();

  String? parsed;

  try {
    parsed = utf8.decode(bytes);
  } catch (e) {
    // Silent fail
  }

  if (parsed == null) {
    try {
      parsed = utf16.decode(bytes);
    } catch (e) {
      // Silent fail
    }
  }

  if (parsed == null) {
    try {
      parsed = utf32.decode(bytes);
    } catch (e) {
      // Silent fail
    }
  }

  if (parsed == null) {
    try {
      parsed = latin1.decode(bytes);
    } catch (e) {
      // Silent fail
    }
  }

  if (parsed == null) {
    throw Exception(
      "Unsupported text encoding. Please provide a CSV with one of following encodings: ascii, utf8, utf16, utf32, latin1",
    );
  }

  final String lineBreaksNormalized = LineBreakNormalizer.normalize(parsed);

  return CsvToListConverter(
    eol: LineBreakNormalizer.terminator,
  ).convert(lineBreaksNormalized);
}
