import 'package:firebase_database/firebase_database.dart';

class Comment {
  String id_user, content, image, date, time;

  Comment(this.id_user, this.content, this.image, this.date, this.time);

  Comment.fromSnapshot(DataSnapshot snapshot){
    id_user = snapshot.value['id_user'];
    content = snapshot.value['content'];
    image = snapshot.value['image'];
    date = snapshot.value['date'];
    time = snapshot.value['time'];
  }

  Comment.map(dynamic obj){
    this.id_user = obj['id_user'];
    this.content = obj['content'];
    this.image = obj['image'];
    this.date = obj['date'];
    this.time = obj['time'];
  }

  Map<String, dynamic> toJSON() {
    return {
      'id_user': id_user, 
      'content': content,
      'image': image,
      'date': date, 
      'time': time
    };
  }
}