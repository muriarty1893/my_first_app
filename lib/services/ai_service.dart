import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/exercise.dart';

class AiService {
  static const String _ollamaUrl = 'https://lavina-snippier-daxton.ngrok-free.dev/api/generate';

  Future<String> generateProgram(String userInput) async {
    try {
      // 1. Get all exercises from the database
      final List<Exercise> allExercises = await DatabaseHelper.instance.getAllExercises();
      if (allExercises.isEmpty) {
        return 'Hata: Veritabanında hiç egzersiz bulunamadı. Lütfen uygulamanın verileri doğru şekilde yüklediğinden emin olun.';
      }

      // 2. Create a summarized list of exercises for the prompt
      // To avoid a huge prompt, we can select a subset or just send titles.
      // For better results, we can filter based on user input, but for now, let's send a random sample.
      final random = Random();
      final sampleSize = min(100, allExercises.length); // Send up to 100 exercises
      final sampledExercises = List.generate(sampleSize, (_) => allExercises[random.nextInt(allExercises.length)]);
      
      final exerciseContext = sampledExercises.map((e) => {
        'title': e.title,
        'bodyPart': e.bodyPart,
        'equipment': e.equipment,
        'level': e.level
      }).toList();

      // 3. Construct the detailed prompt
      final prompt = """
You are an expert fitness coach. Your task is to create a weekly workout program based on the user's request.
ONLY use exercises from the "Available Exercises" list provided below. Do not invent exercises.
The output MUST be a valid JSON object and nothing else. Do not add any explanation before or after the JSON.
The JSON object must have a single root key called "program", which is a list of exercises.
Each exercise in the list must be a JSON object with EXACTLY these four keys: "dayOfWeek", "exerciseTitle", "sets", "reps".
"dayOfWeek" must be one of: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.
"exerciseTitle" MUST EXACTLY match a title from the "Available Exercises" list.
"sets" and "reps" must be integers.

---
User Request: "$userInput"
---
Available Exercises (use only these):
${jsonEncode(exerciseContext)}
---

Remember: Respond with ONLY the raw JSON object.

Example of a valid response:
{
  "program": [
    {
      "dayOfWeek": "Monday",
      "exerciseTitle": "Bench Press",
      "sets": 4,
      "reps": 8
    },
    {
      "dayOfWeek": "Monday",
      "exerciseTitle": "Incline Dumbbell Press",
      "sets": 3,
      "reps": 12
    }
  ]
}
""";

      // 4. Prepare and send the request
      final requestBody = jsonEncode({
        'model': 'llama3:8b',
        'prompt': prompt,
        'format': 'json', // Instruct Ollama to return a guaranteed JSON object
        'stream': false,
      });

      final response = await http.post(
        Uri.parse(_ollamaUrl),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: requestBody,
      );

      // 5. Return the raw JSON response for now
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // The actual JSON program is inside the 'response' key and is a string itself.
        // We need to parse it again.
        return responseBody['response'] ?? 'AI modelinden boş cevap geldi.';
      } else {
        return 'Hata: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      return 'İstek gönderilirken bir sorun oluştu: $e';
    }
  }
}
