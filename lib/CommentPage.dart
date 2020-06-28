import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/CommentCardUI.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'models/Comment.dart';
import 'models/Notify.dart';
import 'models/Post.dart';
import 'models/User.dart';

class CommentPage extends StatefulWidget {
  final Post post;
  final User curUser, userOfPost;

  const CommentPage({Key key, this.post, this.curUser, this.userOfPost}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CommentPage();
  }
  
}

class _CommentPage extends State<CommentPage> {

  User curUser = User();
  List<Comment> listComments = [];
  final TextEditingController eCtrl = new TextEditingController();
  FireStoreService _fireStoreService = FireStoreService();
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  String urlImg = "";
  File commentImage = null;

  @override
  void initState() {

      curUser = this.widget.curUser;
      listComments = this.widget.post.listComments;
    
      
      
      // if(listComments.length > 0 && listComments[0].id_user == "")
      //   listComments.removeAt(0);
      

      databaseReference.child("Post").orderByKey()
      .equalTo(this.widget.post.id).onChildChanged.listen((Event e) {
        Post updatePost = Post.fromSnapshot(e.snapshot);
        if(mounted)
        setState(() {
          listComments = updatePost.listComments;
        });
      });

      

      super.initState();

      
  }

  addComment(String text) async{
    eCtrl.clear();
    if(commentImage != null) 
      await uploadStatusImage();
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy");
    var formatTime = new DateFormat("EEEE, hh:mm:ss:SS aaa");
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    Comment newComment = Comment(curUser.id, text, urlImg, date, time);
    setState(() {
      listComments.add(newComment);
    });

    databaseReference.child("Post").child(this.widget.post.id)
    .update({'comments' : listComments.map((cm) => cm.toJSON()).toList() });

    if(this.widget.userOfPost.id != curUser.id)
    {
      Notify notify = Notify(
        curUser.id, this.widget.userOfPost.id, 
        2, this.widget.post.id, 
        date, time, false
      );
      _fireStoreService.addNotifyList(this.widget.userOfPost.id, notify);
    }
  }

  void uploadStatusImage() async{
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post comment image");
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(commentImage);
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      setState(() {
        urlImg = imageUrl.toString();
        //print(urlImg);
      });
  }

  final picker = ImagePicker();
  void getCommentImage() async {
    final pickerFile = await picker.getImage(imageQuality: 90, source: ImageSource.gallery);
    setState(() {
      commentImage = File(pickerFile.path);
    });
  }

  @override
  void dispose() {
    super.dispose();
    eCtrl.dispose();
  }
  
  

  Widget buildListComment() {
    return 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          //SizedBox(height: 15,),
          Expanded(
            child: listComments.length > 1 ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ListView.builder(
                cacheExtent: pow(10, 10).toDouble(),
                itemCount: listComments.length,
                itemBuilder: (context, index) {
                  if(listComments[index].id_user != "")
                  return CommentCardUI(comment: listComments[index], curUser: curUser,);
                  return SizedBox();
                },
                
              ),
              
            ) : Center(
              child: Text("Hãy là người đầu tiên bình luận"),
            )
          
          ),
          //SizedBox(height: 15,),
          Padding(
              padding: EdgeInsets.only(
                //bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 5, right: 5),
              child: 
              TextField(
                style: TextStyle(
                  fontSize: 16
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  
                  hintText: "Viết bình luận",
                  contentPadding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                  prefixIcon: GestureDetector(
                    child: Icon(Icons.image),
                    onTap: getCommentImage,
                  ),
                  
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.send),
                    onTap: (){addComment(eCtrl.text);},
                  )
                  
                ),
                controller: eCtrl,
                onSubmitted: (value){
                  addComment(value);
                },
                
              ),  
            ),
          
      
      ],
    )
       ;
    
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    resizeToAvoidBottomInset: false,
    resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        actions: <Widget>[],
        title: Text("Bình luận"),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
        child: SingleChildScrollView(
            reverse: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 130),
              child: buildListComment(),
            )
          )
      )
    );
  }
  
}