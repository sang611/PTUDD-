import "package:flutter/material.dart";
import 'package:flutterapp/ProfileFriendPage.dart';
import 'package:intl/intl.dart';

import 'models/Notify.dart';
import 'models/User.dart';
import 'services/FireStoreService.dart';
class UserListCardUI extends StatefulWidget {
  final User user;
  final User curUser;

  const UserListCardUI({Key key, this.user, this.curUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserListCardUI();
  }
  
}

class _UserListCardUI extends State<UserListCardUI> {
  User user, curUser;
  FireStoreService _fireStoreService = FireStoreService();
  bool isFollowed;

  addNotify(int i){
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy");
    var formatTime = new DateFormat("EEEE, hh:mm:ss:SS aaa");
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);
    Notify notify = Notify(curUser.id, user.id, i, "", date, time, false);
    _fireStoreService.addNotifyList(user.id, notify);
  }

  setUserFollow(String id_user, String id_follow) {
      setState((){
        isFollowed = !isFollowed;
      }) ;
      _fireStoreService.addUserFollowing(id_user, id_follow);
      _fireStoreService.addUserFollowed(id_follow, id_user);

      addNotify(4);

  }

  removeUserFollow(String id_user, String id_follow) {
      setState((){
        isFollowed = !isFollowed;
      }) ;
      _fireStoreService.removeUserFollowing(id_user, id_follow);
      _fireStoreService.removeUserFollowed(id_follow, id_user);
  }

  @override
  void initState() {

    user = this.widget.user;
    curUser = this.widget.curUser;
    
    curUser.followingUsers.contains(user.id) ? 
      setState((){
        isFollowed = true;
      }) 
    : setState((){
        isFollowed = false;
      });

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProfileFriendPage(curUser: curUser, friendUser: user)
              )
              );
              
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text(user.username),
            trailing: isFollowed ? FlatButton(
              child: Text(
                "Bỏ theo dõi",
              ), 
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
              textColor: Colors.black87,
              splashColor: Colors.grey,
              padding: EdgeInsets.all(1.0),
              onPressed: (){
                removeUserFollow(this.widget.curUser.id, this.widget.user.id);
              }
            ) : FlatButton(
              child: Text(
                "Theo dõi",
              ), 
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
              textColor: Colors.white,
              splashColor: Colors.grey,
              padding: EdgeInsets.all(1.0),
              onPressed: (){
                setUserFollow(this.widget.curUser.id, this.widget.user.id);
              }
            )
            ,
          );
  }
  
}