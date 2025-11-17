class Exercise {
  final int id;
  final String title;
  final String desc;
  final String type;
  final String bodyPart;
  final String equipment;
  final String level;
  final double? rating;
  final String? ratingDesc;

  Exercise({
    required this.id,
    required this.title,
    required this.desc,
    required this.type,
    required this.bodyPart,
    required this.equipment,
    required this.level,
    this.rating,
    this.ratingDesc,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      title: map['title'] as String,
      desc: map['desc'] as String,
      type: map['type'] as String,
      bodyPart: map['bodyPart'] as String,
      equipment: map['equipment'] as String,
      level: map['level'] as String,
      rating: map['rating'] as double?,
      ratingDesc: map['ratingDesc'] as String?,
    );
  }

  factory Exercise.fromList(List<dynamic> list) {
    return Exercise(
      id: list[0] is int ? list[0] : int.tryParse(list[0].toString()) ?? 0,
      title: list[1].toString(),
      desc: list[2].toString(),
      type: list[3].toString(),
      bodyPart: list[4].toString(),
      equipment: list[5].toString(),
      level: list[6].toString(),
      rating: double.tryParse(list[7].toString()),
      ratingDesc: list.length > 8 ? list[8]?.toString() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'type': type,
      'bodyPart': bodyPart,
      'equipment': equipment,
      'level': level,
      'rating': rating,
      'ratingDesc': ratingDesc,
    };
  }
}
