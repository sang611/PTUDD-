import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/CommentPage.dart';
import 'package:flutterapp/DialogBox.dart';
import 'package:flutterapp/services/CalculateTime.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'ProfileFriendPage.dart';
import 'models/Comment.dart';
import 'models/Notify.dart';
import 'models/Post.dart';
import 'models/User.dart';

class PostCardUI extends StatefulWidget {
  final Post post;
  final User curUser;

  const PostCardUI({Key key, this.post, this.curUser}) : super(key: key);
  

  @override
  State<StatefulWidget> createState() {
    print(post.image);
    return _PostCardUI();
  }
}

class _PostCardUI extends State<PostCardUI> {
  User userOfPost = User();
  User curUser = User();
  User shareFromUser = User();
  int like;
  bool isLiked = false;
 
  var theImage, theAvatar;
  
  List<Comment> listComments = [];
  List<String> listUsersLiked = [""];

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  FireStoreService _fireStoreService = FireStoreService();
  final Firestore _collectionReference = Firestore.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
 
  @override
  void initState() {
    //super.initState();
    
    
    like = this.widget.post.like;
    curUser = this.widget.curUser;
    listUsersLiked = this.widget.post.listUserLiked;
    isLiked = this.widget.post.listUserLiked.contains(curUser.id);

    databaseReference.child("Post").orderByKey()
    .equalTo(this.widget.post.id)
    .onChildChanged.listen((Event e) {
      Post updatePost = Post.fromSnapshot(e.snapshot);
      if(mounted)
      setState(() {
        like = updatePost.like;
        listUsersLiked = updatePost.listUserLiked;
        isLiked = updatePost.listUserLiked.contains(curUser.id);
      });
    });
    

    if(this.widget.post.type == 2) {
      _controller = VideoPlayerController.network(this.widget.post.image);
      _initializeVideoPlayerFuture = _controller.initialize();
    }

    _fireStoreService.getUser(this.widget.post.user_id).then((_user){
      if(mounted)
      setState(() {
        userOfPost = _user;
        //theAvatar = NetworkImage(userOfPost.avatar);
      });
    });

    if(this.widget.post.shareFrom != "")
    _fireStoreService.getUser(this.widget.post.shareFrom).then((_user){
      if(mounted)
      setState(() {
        shareFromUser = _user;
      });
    });

    if(this.widget.post.type == 1)
    theImage = Image.network(
                this.widget.post.image,
                fit: BoxFit.fill
              );

    _collectionReference.collection("users")
    .snapshots().listen((result) {
      result.documentChanges.forEach( (value) {
        if(value.type == DocumentChangeType.modified && 
          value.document.data['id'] == curUser.id) {
          User updateUser = User.fromData(value.document.data);
          if(mounted)
          setState(() {
            curUser = updateUser;
          });
        }
       });
    });

    super.initState();          
    
  }

  @override
    void didChangeDependencies() {
    if(this.widget.post.type == 1)
    precacheImage(theImage.image, context);
    // if(theAvatar != null)
    // precacheImage(theAvatar.image, context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if(_controller != null)
    _controller.dispose();
    super.dispose();
  }

  addNotify(int i){
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy");
    var formatTime = new DateFormat("EEEE, hh:mm:ss:SS aaa");
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);
    Notify notify = Notify(curUser.id, userOfPost.id, i, this.widget.post.id, date, time, false);
    _fireStoreService.addNotifyList(userOfPost.id, notify);
  }
  
  setLike(){
    Post post = this.widget.post;
    if (isLiked) 
    {
      removeUserLiked(curUser.id);
      setState(() {
        //this.widget.post.like = post.like - 1;
        like = like - 1;
      });
      //post.like --;
    }  
    else {
      addUserLiked(curUser.id);
      setState(() {
        //this.widget.post.like = post.like + 1;
        like = like + 1;
      });
      //post.like ++;
      if(curUser.id != userOfPost.id)
      addNotify(1);
    }

    if(mounted)
    setState(() {
      isLiked = !isLiked;
    });
    // databaseReference.child('Post').child(post.id).update({'like': this.widget.post.like});
    databaseReference.child('Post').child(post.id).update({'like': like});
  }


  addUserLiked(String id) {
    setState(() {
      listUsersLiked.add(id);
    });

    databaseReference.child('Post').child(this.widget.post.id)
    .update({'usersLiked' : listUsersLiked });
  }

  removeUserLiked(String id) {
    setState(() {
      listUsersLiked.remove(id);
    });
    databaseReference.child('Post').child(this.widget.post.id)
    .update({'usersLiked' : listUsersLiked });
  }

  

  sharePost(){
    Post post = this.widget.post;
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    DialogBox dialogBox = DialogBox();

    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy");
    var formatTime = new DateFormat("EEEE, hh:mm:ss:SS aaa");

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);


    var sharedPost = Post(
      post.image, post.description, 
      date, time, 0, 
      curUser.id, post.listComments,
      post.listUserLiked, post.sharedNum+1, 
      post.type, 1, userOfPost.id
    );

    databaseReference.child("Post").child(post.id).update({"sharedNum": post.sharedNum+1});
    databaseReference.child("Post").push().set(sharedPost.toJSON()).then((v){
      dialogBox.information(context, "Đã chia sẻ bài viết", "Bạn bè có thể nhìn thấy chia sẻ của bạn");
      addNotify(3);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    Post post = this.widget.post;
    int commentNum;
    commentNum = post.listComments.length - 1;
    int sharedNum = post.sharedNum;

    String tile = "";
     
       if(post.isShared == 1){
          if(shareFromUser.id != curUser.id)
            tile = " đã chia sẻ bài viết của " + shareFromUser.username.toString();
          else 
            tile = " đã chia sẻ bài viết của bạn";
      }

    return 
    Card (
      elevation: 20.0,
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: new Container(
        child: new Column(
          children: <Widget>
          [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.5),
              child: new Row(
                children: <Widget>[
                  GestureDetector(
                  onTap: (curUser.id != userOfPost.id) ? (){
                    Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProfileFriendPage(curUser: curUser, friendUser: userOfPost)
                      )
                    );
                  } : (){},
                  child: userOfPost.avatar != null ? CircleAvatar(
                    backgroundImage: NetworkImage(userOfPost.avatar) 
                  ) : CircularProgressIndicator()
                  ),
                  GestureDetector(
                  onTap: (curUser.id != userOfPost.id) ? (){
                    
                    Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProfileFriendPage(curUser: curUser, friendUser: userOfPost)
                      )
                    );
                  } : (){
                    
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              userOfPost.username != null ? "" + userOfPost.username : "",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                           
                            Text(
                                (shareFromUser.username != null) ? tile : "",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 3,),
                        Row(
                          children: <Widget>[
                            new Text(
                                  CalculateTime.calculateTime(post.date, post.time),
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12
                                  ),
                                  //textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                  
                ],
              ),
            ),
            SizedBox(height: 8.0,),
            
            post.description != "" ? Padding(
              padding: const EdgeInsets.fromLTRB( 5.0, 0, 5.0, 8 ),
              child: new Text(
                post.description,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ) : SizedBox(height: 0.0,), 

            SizedBox(height: 5.0,),
            
            post.type == 1 ? GestureDetector(
              onDoubleTap: setLike,
              child: Center(
              //   child: Image.network(
              //   this.widget.post.image,
              //   fit: BoxFit.fill
                
              // )
              child: theImage!= null ? theImage : SizedBox()
              )
              
              
            ) : 
            Chewie(
              controller: ChewieController(
              videoPlayerController: _controller,
              aspectRatio: _controller.value.aspectRatio,
              autoPlay: false,
              looping: false,
            )
            ),
            
          
            SizedBox(height: 10.0,),

            Padding(
              padding: EdgeInsets.fromLTRB(5.5, 15.0, 5.5, 5),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                        new Text(
                          "$like lượt thích",
                          style: this.isLiked 
                          ? TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold
                          ) 
                          : TextStyle(
                            color: Colors.grey,
                            
                          ),
                        ),

                        new Text(
                          "$commentNum bình luận . $sharedNum lượt chia sẻ",
                          style: new TextStyle(
                            color: Colors.blueGrey,
                          ),
                        )
                ],
              ),
            ),

            Center(
              child: Container(
                  color: Colors.grey[300],
                  width: 500,
                  height: 1,
            )
            ),
            
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                children: <Widget>[
                  IconButton(
                    icon: this.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                    color: this.isLiked ? Colors.red : Colors.grey,
                    onPressed: setLike,
                  ),
                ]
                 ), 
                

                  IconButton(
                  icon: Icon(Icons.comment),
                  color: Colors.grey, 
                  onPressed: () {
                    Post post = this.widget.post;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CommentPage(post: post, curUser: curUser, userOfPost: userOfPost)
                    )
                    );
                  },
                ),

                new IconButton(
                  icon: new Icon(Icons.share),
                  color: Colors.grey, 
                  onPressed: sharePost,
                )
              ],
              
            ),

            
          ],

          crossAxisAlignment: CrossAxisAlignment.start,
        )
      ),
    );
  }
  
}