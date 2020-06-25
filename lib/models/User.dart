import 'package:flutterapp/models/Notify.dart';

class User{
  String avatar, id, username, email, password;
  List<String> followingUsers = [];
  List<String> followedUsers = [];
  List<String> postedList = [];
  List<Notify> notifyList = [];

  User({this.avatar, this.id, this.username, 
        this.email, this.password, this.followingUsers,
        this.followedUsers ,this.postedList, this.notifyList});

  User.fromData(Map<String, dynamic> data)
      : avatar = data['avatar'],
        id = data['id'],
        username = data['username'],
        email = data['email'],
        password = data['password'],
        followingUsers = (data['followingUsers'] as List).map((ele) => ele.toString()).toList(),
        followedUsers = (data['followedUsers'] as List).map((ele) => ele.toString()).toList(),
        postedList = (data['postedList'] as List).map((ele) => ele.toString()).toList(),
        notifyList = (data['notifyList'] as List).map((ele) => Notify.map(ele)).toList();

  Map<String, dynamic> toJSON() {
    return {
      'avatar': avatar,
      'id': id,
      'username': username,
      'email': email,
      'followingUsers': followingUsers,
      'followedUsers': followedUsers,
      'postedList': postedList,
      'notifyList': notifyList
    };
  }
}