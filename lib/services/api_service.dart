import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String?> fetchTodoTitle() async {
    try {
      final response = await http.get(
    Uri.parse('https://api.publicapis.org/entries'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
return data['entries'][0]['Description'];
      } else {
        return "Greška: ${response.statusCode}";
      }
    } catch (e) {
      return "Došlo je do greške prilikom učitavanja API podataka.";
    }
  }
}