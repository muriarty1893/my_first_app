import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/exercise.dart';

class AiService {
  static const String _ollamaUrl = 'https://lavina-snippier-daxton.ngrok-free.dev/api/generate';

  Future<String> generateProgram(
    String userInput, {
    String? levelFilter,
    bool isFullBody = false,
  }) async {
    try {
      // 1. Get all exercises from the database
      List<Exercise> allExercises = await DatabaseHelper.instance.getAllExercises();
      if (allExercises.isEmpty) {
        return 'Hata: Veritabanında hiç egzersiz bulunamadı. Lütfen uygulamanın verileri doğru şekilde yüklediğinden emin olun.';
      }

      // Apply level filter if provided
      if (levelFilter != null && levelFilter != 'Any') {
        allExercises = allExercises.where((e) => e.level == levelFilter).toList();
      }
      
      if (allExercises.isEmpty) {
        return 'Hata: Seçilen filtreleme kriterlerine uygun egzersiz bulunamadı.';
      }

      // 2. Create a summarized list of exercises for the prompt
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
      String filterInstructions = '';
      if (levelFilter != null && levelFilter != 'Any') {
        filterInstructions += " The workout program should be suitable for a '$levelFilter' level user.";
      }
      if (isFullBody) {
        filterInstructions += " The program should be a full-body workout, covering all major muscle groups throughout the week.";
      }

      final prompt = """
You are an expert fitness coach. Your task is to create a weekly workout program based on the user's request.
ONLY use exercises from the "Available Exercises" list provided below. Do not invent exercises.
The output MUST be a valid JSON object and nothing else. Do not add any explanation before or after the JSON.
The JSON object must have a single root key called "program", which is a list of exercises.
Each exercise in the list must be a JSON object with EXACTLY these four keys: "dayOfWeek", "exerciseTitle", "sets", "reps".
"dayOfWeek" must be one of: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.
"exerciseTitle" MUST EXACTLY match a title from the "Available Exercises" list.
"sets" and "reps" must be integers.
$filterInstructions

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
