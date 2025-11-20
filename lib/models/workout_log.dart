class WorkoutLog {
  final int? id;
  final int exerciseId;
  final String exerciseTitle;
  final int sets;
  final int reps;
  final DateTime date;

  WorkoutLog({
    this.id,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.sets,
    required this.reps,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseTitle': exerciseTitle,
      'sets': sets,
      'reps': reps,
      'date': date.toIso8601String(),
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'],
      exerciseId: map['exerciseId'],
      exerciseTitle: map['exerciseTitle'],
      sets: map['sets'],
      reps: map['reps'],
      date: DateTime.parse(map['date']),
    );
  }
}
