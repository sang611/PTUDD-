import 'package:firebase_database/firebase_database.dart';

class Notify {

  String idUserA, idUserB, postId ,date, time;
  int type;
  bool seen;

  Notify(this.idUserA, this.idUserB, 
          this.type, this.postId, 
          this.date, this.time, this.seen
        );

  Notify.fromSnapshot(DataSnapshot snapshot){
    idUserA = snapshot.value['idUserA'];
    idUserB = snapshot.value['idUserB'];
    type = snapshot.value['type'];
    postId = snapshot.value['postId'];
    date = snapshot.value['date'];
    time = snapshot.value['time'];
    seen = snapshot.value['seen'];
  }

  Notify.map(dynamic obj){
    this.idUserA = obj['idUserA'];
    this.idUserB = obj['idUserB'];
    this.type = obj['type'];
    this.postId = obj['postId'];
    this.date = obj['date'];
    this.time = obj['time'];
    this.seen = obj['seen'];
  }

  Map<String, dynamic> toJSON() {
    return {
      'idUserA': idUserA, 
      'idUserB': idUserB,
      'type': type,
      'postId': postId,
      'date': date, 
      'time': time,
      'seen': seen
    };
  }
}