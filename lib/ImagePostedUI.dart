import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'PostPersonalPage.dart';
import 'models/Post.dart';
import 'models/User.dart';
class ImagePostedUI extends StatefulWidget {
  final String postId;
  //final Post post;
  final User curUser;
  //final int index;

  const ImagePostedUI({Key key, this.postId, this.curUser}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ImagePostedUI();
  }

}

class _ImagePostedUI extends State<ImagePostedUI>{

  Post post;
  var theImage;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  final Firestore _collectionReference = Firestore.instance;
  @override
  void initState() {
    
    
    
    databaseReference.child("Post").child(this.widget.postId).once().then((value) {
      setState((){
        post = Post.fromSnapshot(value);
        if(post.type == 1)
          theImage = Image.network(
                      post.image,
                      fit: BoxFit.fill
                    );
        else {
          // _controller = VideoPlayerController.network("https://player.vimeo.com/external/391912239.sd.mp4?s=7d2d35ed7ae49f514e8cc05505745db90f733302&profile_id=139&oauth2_token_id=57447761");
          // _initializeVideoPlayerFuture = _controller.initialize();
          // theImage = Chewie(
          //     controller: ChewieController(
          //     videoPlayerController: _controller,
          //     aspectRatio: 1/1,
          //     autoPlay: false,
          //     looping: false,
          //   )
          //   );
          theImage = Image.network(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTBouC6Z8v0WkxLIBpiQtTdtsCO5ig0ub2f4g&usqp=CAU",
                      fit: BoxFit.fill
                    );
        }
                    
          
      });
    });

    super.initState();

  }

  @override
    void didChangeDependencies() {
    if(theImage != null && post!=null && post.type == 1)
    precacheImage(theImage.image, context);
    super.didChangeDependencies();
  }

  

  Future findPost() async{
    await databaseReference.child("Post").child(this.widget.postId).once().then((value) {
      if(mounted)
      setState((){
        post = Post.fromSnapshot(value);
        if(post.type == 1)
          theImage = Image.network(
                      post.image,
                      fit: BoxFit.fill
                    );
        else {
          // _controller = VideoPlayerController.network(post.image);
          // _initializeVideoPlayerFuture = _controller.initialize();
          // theImage = Chewie(
          //     controller: ChewieController(
          //     videoPlayerController: _controller,
          //     aspectRatio: 1/1,
          //     autoPlay: false,
          //     looping: false,
          //   )
          //   );
          theImage = Image.network(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTBouC6Z8v0WkxLIBpiQtTdtsCO5ig0ub2f4g&usqp=CAU",
                      fit: BoxFit.fill
                    );

        }
      });
    });
    return post;
  }

  @override
  void dispose() {
    if(_controller != null)
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    findPost().then((value) {
      if(mounted)
            setState((){
              post = value;
            });
          });
    return GestureDetector(
    child: theImage!= null ? theImage : CircularProgressIndicator()
    ,
    onTap: (){
      print(this.widget.postId);
      findPost().then((value) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => 
            PostPersonalPage(post: value, curUser: this.widget.curUser)
        ));
      });
      
    }
    );
    
  
}
}