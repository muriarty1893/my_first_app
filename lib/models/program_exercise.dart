class ProgramExercise {
  final int? id;
  final int exerciseId;
  final String exerciseTitle;
  final String dayOfWeek; // e.g., "Monday", "Tuesday"
  int sets;
  int reps;
  bool isCompleted;

  ProgramExercise({
    this.id,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.dayOfWeek,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseTitle': exerciseTitle,
      'dayOfWeek': dayOfWeek,
      'sets': sets,
      'reps': reps,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory ProgramExercise.fromMap(Map<String, dynamic> map) {
    return ProgramExercise(
      id: map['id'],
      exerciseId: map['exerciseId'],
      exerciseTitle: map['exerciseTitle'],
      dayOfWeek: map['dayOfWeek'],
      sets: map['sets'],
      reps: map['reps'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
