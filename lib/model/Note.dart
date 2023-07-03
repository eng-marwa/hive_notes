
import 'package:hive_flutter/hive_flutter.dart';
part 'Note.g.dart';
@HiveType(typeId: 0)
class Note{
  @HiveField(0)
  String? title;
  @HiveField(1)
  String? body;
  @HiveField(2)
  String? date;

  Note(this.title, this.body, this.date);


}