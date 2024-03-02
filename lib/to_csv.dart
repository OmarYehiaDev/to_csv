library to_csv;

import 'dart:io';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

Future myCSV(
  List<String> headerRow,
  List<List<String>> listOfListOfStrings, {
  bool sharing = false,
  String? fileName,
  String? fileTimeStamp,
}) async {
  if (kDebugMode) {
    print("***** Gonna Create cv");
  }
  String givenFileName = fileName ?? "item_export";

  DateTime now = DateTime.now();

  String formattedDate = fileTimeStamp ?? DateFormat('MM-dd-yyyy-HH-mm-ss').format(now);

  List<List<String>> headerAndDataList = [];
  headerAndDataList.add(headerRow);
  for (var dataRow in listOfListOfStrings) {
    headerAndDataList.add(dataRow);
  }

  String csvData = const ListToCsvConverter().convert(headerAndDataList);

  if (kIsWeb) {
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = '$givenFileName$formattedDate.csv';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  } else if (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS) {
    final bytes = utf8.encode(csvData);
    Uint8List bytes2 = Uint8List.fromList(bytes);
    MimeType mimeType = MimeType.csv;
    if (sharing == true) {
      XFile xFile = XFile.fromData(bytes2, mimeType: mimeType.type, name: "$givenFileName.csv");
      await Share.shareXFiles([xFile], text: 'CSV File');
    } else {
      String? unknownValue = await FileSaver.instance.saveAs(
        name: '${givenFileName}_$formattedDate.csv',
        bytes: bytes2,
        ext: 'csv',
        mimeType: mimeType,
      );
      if (kDebugMode) {
        print("Unknown value $unknownValue");
      }
    }
  }
}
