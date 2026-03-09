import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String authorId;

  @HiveField(5)
  final String teamId;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final bool isPublic;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.authorId,
    required this.teamId,
    required this.category,
    this.isPublic = false,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'title': title,
      'description': description,
      'date': date,
      'authorId': authorId,
      'teamId': teamId,
      'category': category,
      'isPublic': isPublic,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id']?.oid ?? map['_id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? DateTime.now().toString(),
      authorId: map['authorId'] ?? 'unknown_user',
      teamId: map['teamId'] ?? 'no_team',
      category: map['category'] ?? 'Other',
      isPublic: map['isPublic'] ?? false,
    );
  }

  LogModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? authorId,
    String? teamId,
    String? category,
    bool? isPublic,
  }) {
    return LogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      authorId: authorId ?? this.authorId,
      teamId: teamId ?? this.teamId,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
