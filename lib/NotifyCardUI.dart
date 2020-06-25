import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/PostPersonalPage.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'ProfileFriendPage.dart';
import 'models/Post.dart';
import 'models/User.dart';
import 'models/Notify.dart';
import 'services/CalculateTime.dart';

class NotifyCardUI extends StatefulWidget {

  final Notify notify;
  final User curUser;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const NotifyCardUI({Key key, this.notify, this.curUser, this.scaffoldKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NotifyCardUI();
  }
}

class _NotifyCardUI extends State<NotifyCardUI>{

  FireStoreService fireStoreService = FireStoreService();
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  User userA, userB;
  Post post;
  Notify notify;
  bool seen = false;
  final Firestore _collectionReference = Firestore.instance;

  @override
  void initState() {
    
    

    setState(() {
      notify = this.widget.notify;
      seen = notify.seen;
    });

    fireStoreService.getUser(this.widget.notify.idUserA).then((value){
      setState(() {
        userA = value;
      });
    });
    fireStoreService.getUser(this.widget.notify.idUserB).then((value){
      setState(() {
        userB = value;
      });
    });

    databaseReference.child("Post").child(notify.postId).once().then((value) {
      setState((){
        post = Post.fromSnapshot(value);
      });
    });

    super.initState();
  }

  Future findPost(id) async{
    await databaseReference.child("Post").child(notify.postId).once().then((value) {
      setState((){
        post = Post.fromSnapshot(value);
        print(post.like);
        print(post.isLiked);
      });
    });
    return post;
  }

  @override
  void dispose() {
    super.dispose();
  }
  

  Widget buildTextNotify(User userA, Notify notify) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontSize: 17
            ),
            children: <TextSpan>[
              TextSpan(
                text: userA.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontSize: 15.5
                ),
                text: (this.widget.notify.type == 1) ? " đã thích một bài viết của bạn." 
                                         : " đã bình luận về một bài viết của bạn."
              )
            ]
           
          )
          ),
          SizedBox(height: 8.0),
          Text(
            CalculateTime.calculateTime(this.widget.notify.date, this.widget.notify.time),
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12
            ),
          ),
        ],
      );
  }

  

  @override
  Widget build(BuildContext context) {
    return (userA != null && post != null && userB != null) ? 
          Container(
            decoration: BoxDecoration(
              color: !this.widget.notify.seen ? Colors.lightBlue[50] : Colors.white10,
              
            ),
            
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 8, right: 8),
              leading: GestureDetector(
                child: CircleAvatar(
                    backgroundImage: userA.avatar != null ? NetworkImage(userA.avatar) : NetworkImage("https://lh3.googleusercontent.com/proxy/YWLMxIDoaKECruTCkjLGyj6TZpngk3KMh4Le_uIWpwaIKQnPC6HcWjhNMM5kAR9UyzYp8zzjPN6BtJPgGPvlt84zCuXFrprQF1vUHrCTZOs7LTmqgeYBAjmFo8WACRfnXXPFRzlxI2pM2g"),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfileFriendPage(curUser: this.widget.curUser, friendUser: userA)
                    )
                  );
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildTextNotify(userA, notify),
                ],
              ),
              onTap: (){
                // fireStoreService.updateNotifyList(userB.id, notify).then((value){
                  
                //   Navigator.push(context, MaterialPageRoute(
                //     builder: (context) => 
                //     PostPersonalPage(post: post, curUser: userB)
                // ));
                
                // });

                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => 
                    PostPersonalPage(post: post, curUser: userB)
                ));

                fireStoreService.updateNotifyList(userB.id, notify);
                
                
                
              },
            ) 
    )
    : SizedBox(height: 0.0);
  }
  
}