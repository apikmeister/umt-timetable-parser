import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Map<String, dynamic> getUserData(String body) {
  var document = parse(body);

  var address =
      document.querySelector('input[name="alamatsurat"]')?.attributes['value'];

  var phoneNo =
      document.querySelector('input[name="nohp"]')?.attributes['value'];

  // Find row with Nama/Name
  var nameRow = document.querySelector(
      "tr td .text:contains('Nama'), tr td .text:contains('Name')");

  // If nameRow is null, return with empty values
  if (nameRow == null) {
    return {'name': '', 'address': address, 'phoneNo': phoneNo};
  }

  var nameTd = nameRow.nextElementSibling?.nextElementSibling;

  // If nameTd or its child span is null, return with empty name
  if (nameTd == null || nameTd.querySelector('span') == null) {
    return {'name': '', 'address': address, 'phoneNo': phoneNo};
  }

  var name = nameTd.querySelector('span')!.text;

  // Add more data extraction logic here...

  return {'name': name, 'address': address, 'phoneNo': phoneNo};
}
