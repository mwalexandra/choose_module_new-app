class Module {
  final String id;
  final String name;
  final String dozent;
  final int maxParticipants;
  int participants;
  bool isSelected;

  Module({
    required this.id,
    required this.name,
    required this.dozent,
    required this.maxParticipants,
    this.participants = 0,
    this.isSelected = false,
  });

  // Создать из Map Firebase
  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dozent: map['dozent'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 20,
      participants: map['participants'] ?? 0,
      isSelected: false,
    );
  }

  // Преобразовать в Map для сохранения в Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dozent': dozent,
      'maxParticipants': maxParticipants,
      'participants': participants,
    };
  }
}
