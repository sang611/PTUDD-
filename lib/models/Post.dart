import 'package:firebase_database/firebase_database.dart';
import 'Comment.dart';
import 'User.dart';

class Post{
  String id, image, description, date, time, user_id, shareFrom;
  int like;
  bool isLiked = false;
  int sharedNum = 0;
  int type;
  int isShared;
  List<Comment> listComments = [];
  List<String> listUserLiked = [];
  

  Post (
        this.image, this.description, 
        this.date, this.time, this.like, 
        this.user_id, this.listComments,
        this.listUserLiked, this.sharedNum, 
        this.type, this.isShared, this.shareFrom
       );

  set setIsLiked(bool isLiked){
    this.isLiked = isLiked;
  }

  bool get getIsLiked{
    return this.isLiked;
  }


  Post.map(dynamic obj){
    this.id = obj['id'];
    this.image = obj['image'];
    this.description = obj['description'];
    this.date = obj['date'];
    this.time = obj['time'];
    this.like = obj['like'];
    this.user_id = obj['user_id'];
    this.listComments = obj['comments'];
    this.listUserLiked = obj['usersLiked'];
    this.sharedNum = obj['sharedNum'];
    this.type = obj['type'];
    this.isShared = obj['isShared'];
    this.shareFrom = obj['shareFrom'];
  }

  Post.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    image = snapshot.value['image'];
    description = snapshot.value['description'];
    date = snapshot.value['date'];
    time = snapshot.value['time'];
    like = snapshot.value['like'];
    user_id = snapshot.value['user_id'];
    listComments = (snapshot.value['comments'] as List).map((e) => (Comment.map(e))).toList();
    listUserLiked = (snapshot.value['usersLiked'] as List).map((e) => e.toString()).toList();
    sharedNum = snapshot.value['sharedNum'];
    type = snapshot.value['type'];
    isShared = snapshot.value['isShared'];
    shareFrom = snapshot.value['shareFrom'];
  }

  Post.fromData(String id, Map<String, dynamic> data)
      : id = id,
        image = data['image'],
        description = data['description'],
        date = data['date'],
        time = data['time'],
        like = data['like'],
        user_id = data['user_id'],
        listComments = (data['followingUsers']!=null ? data['followingUsers'] as List : []).map((ele) => (Comment.map(ele))).toList(),
        listUserLiked = (data['usersLiked']!=null ? data['usersLiked'] as List : []).map((ele) => (ele.toString())).toList(),
        sharedNum = data['sharedNum'],
        type = data['type'],
        isShared = data['isShared'],
        shareFrom = data['shareFrom'];

  Map<String, dynamic> toJSON() {
    return {
      'image': image, 
      'description': description, 
      'date': date,
      'time': time,
      'like': like,
      'user_id': user_id,
      'comments': listComments.map((comment) => comment.toJSON()).toList(),
      'usersLiked': listUserLiked,
      'sharedNum': sharedNum,
      'type': type,
      'isShared': isShared,
      'shareFrom': shareFrom
    };
  }

}