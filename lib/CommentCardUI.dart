import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'ProfileFriendPage.dart';
import 'models/Comment.dart';
import 'models/User.dart';
import 'services/CalculateTime.dart';

class CommentCardUI extends StatefulWidget {
  final Comment comment;
  final User curUser;
  const CommentCardUI({Key key, this.comment, this.curUser}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
   return _CommentCardUI();
  }
  
}

class _CommentCardUI extends State<CommentCardUI> {
  User user = User();
  File commentImage;
  FireStoreService fireStoreService = FireStoreService();

  @override
  void initState() {
    
    

    fireStoreService.getUser(this.widget.comment.id_user).then((value){
      if(mounted)
      setState(() {
        user = value;
      });
    });

    super.initState();

  }

  

  @override
  Widget build(BuildContext context) {
    User curUser = this.widget.curUser;
    User commentUser = user;
    return user != null ? 
          Container(
            margin: EdgeInsets.only(top: 7.5, bottom: 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                child: CircleAvatar(
                    backgroundImage: user.avatar != null ? NetworkImage(user.avatar) : NetworkImage("https://lh3.googleusercontent.com/proxy/YWLMxIDoaKECruTCkjLGyj6TZpngk3KMh4Le_uIWpwaIKQnPC6HcWjhNMM5kAR9UyzYp8zzjPN6BtJPgGPvlt84zCuXFrprQF1vUHrCTZOs7LTmqgeYBAjmFo8WACRfnXXPFRzlxI2pM2g"),
                ),
                
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfileFriendPage(curUser: curUser, friendUser: commentUser)
                    )
                  );
                },
              ),
              Container(
              margin: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.username != null ? user.username : "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent
                        ),
                      ),

                      Text(this.widget.comment.content),
                    ],
                  ),
                  ),
                  //SizedBox(height: 5.0),
                  this.widget.comment.image != "" ? Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    width: 160,
                    height: 90,
                    alignment: Alignment.topLeft,
                    child: Image.network(this.widget.comment.image) ,
                  ) : SizedBox(height: 0),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        CalculateTime.calculateTime(this.widget.comment.date, this.widget.comment.time),
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12
                        ),     
                    ),
                  ),
                ],
              )
              ),
              ]
    ) )
    : "";
    
  }
  
}
