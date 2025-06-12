import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  static Future<String> ask(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Clé API manquante !");
      return "❌ Clé API OpenAI manquante. Vérifie ton fichier .env.";
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": "Tu es un assistant agricole expert, clair et précis.",
            },
            {
              "role": "user",
              "content": prompt,
            }
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        print("❌ Erreur API (${response.statusCode})");
        print("🔎 Réponse OpenAI : ${response.body}");
        return "Désolé, je n'ai pas pu obtenir de réponse. Réessaye plus tard.";
      }
    } catch (e) {
      print("❌ Exception OpenAI : $e");
      return "Erreur lors de la connexion à l'assistant IA.";
    }
  }
}
