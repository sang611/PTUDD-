import 'package:flutterapp/models/Comment.dart';

import 'package:firebase_database/firebase_database.dart';

class Chat {
  String idUser1, idUser2;
  List<Comment> messageList;

  Chat(this.idUser1, this.idUser2, this.messageList);

  Chat.fromSnapshot(DataSnapshot snapshot){
    idUser1 = snapshot.value['id_user'];
    idUser2 = snapshot.value['content'];
    messageList = (snapshot.value['messageList'] as List).map((ele) => Comment.map(ele)).toList();
  }

  Chat.fromData(Map<String, dynamic> data)
      : idUser1 = data['idUser1'],
        idUser2 = data['idUser2'],
        messageList = (data['messageList'] as List).map((ele) => Comment.map(ele)).toList();
        

  Map<String, dynamic> toJSON() {
    return {
      'idUser1': idUser1,
      'idUser2': idUser2,
      'messageList': messageList,
      
    };
  }
}