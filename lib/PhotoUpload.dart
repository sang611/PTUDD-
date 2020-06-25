import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'models/Comment.dart';
import 'models/Post.dart';
import 'models/User.dart';
import 'services/Authentication.dart';
import 'DialogBox.dart';
import 'services/FireStoreService.dart';

class PhotoUploadPage extends StatefulWidget{
  
  const PhotoUploadPage({Key key, this.auth}) : super(key: key);

  final AuthImplementation auth;
  //final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {
    return _PhotoUploadState();
      }
      
    }
    
class _PhotoUploadState extends State<PhotoUploadPage>{
  File sampleImage, sampleVideo;
  final formKey = new GlobalKey<FormState>();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  String myValue;
  String url;
  User curUser = new User();
  FireStoreService fireStoreService = FireStoreService();
  bool isLoading = false;

  @override
  void initState() {
    

    widget.auth.populateCurrentUser().then((user){
      setState(() {
        curUser = user;
      });
      
    });

    super.initState();
  }
  


  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  void uploadStatusImage() async{
    if(validateAndSave()){
      setState(() {
        isLoading = true;
      });
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post image");
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      url = imageUrl.toString();
      print(url);
      saveToDatabase(url);
    }
  }

  void uploadStatusVideo() async{
    if(validateAndSave()){
      setState(() {
        isLoading = true;
      });
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post video");
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".mp4").putFile(sampleVideo);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      url = imageUrl.toString();

      //print(url);
      saveToDatabase(url);
    }
  }


  void saveToDatabase(url){
    //print(this.curUser.id);
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy");
    var formatTime = new DateFormat("EEEE, hh:mm:ss:SS aaa");

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);
    
    String user_id = this.curUser.id;
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    
    
    List<Comment> comments = [Comment("", "", "", "", "")];
    List<String> usersLiked = [""];
    int sharedNum = 0;
    int type = sampleImage != null ? 1 : 2;
    var newPost = Post( url, myValue, date, time, 
                        0, user_id, comments, usersLiked,
                        sharedNum, type, 0, "");
    String key = databaseReference.child("Post").push().key;
    databaseReference.child("Post").child(key).set(newPost.toJSON()).whenComplete(() {
      fireStoreService.addPostedList(curUser.id, key);
      setState(() {
        isLoading = false;
      });
      //print("ID la"+key);
    });
    
    
    DialogBox dialogBox = new DialogBox();
    dialogBox.information(context, "Thành công", "Bạn bè của bạn sẽ nhìn thấy bài viết này");
    setState(() {
      sampleImage= null;
      sampleVideo = null;
    });
  }

  final picker = ImagePicker();

  void getImageFromGallery() async {
    final pickerFile = await picker.getImage(imageQuality: 90, source: ImageSource.gallery);
    setState(() {
      sampleImage = File(pickerFile.path);
      sampleVideo = null;
    });
  }

  void getVideoFromGallery() async {
    final pickerFile = await picker.getVideo(source: ImageSource.gallery);
    setState(() {
      sampleVideo = File(pickerFile.path);
      _controller = VideoPlayerController.file(sampleVideo);
      _initializeVideoPlayerFuture = _controller.initialize();
      sampleImage = null;
    });
  }

  void getCamera() async {
    final pickerFile = await picker.getImage(imageQuality: 90, source: ImageSource.camera);
    print(File(pickerFile.path));
    final LostData response = await picker.getLostData();
    if(response.file != null)
      setState(() {
        sampleImage = File(response.file.path);
        sampleVideo = null;
      });
    else 
      setState(() {
        sampleImage = File(pickerFile.path);
        sampleVideo = null;
      });
  }

  void getVideo() async {
    final pickerFile = await picker.getVideo( source: ImageSource.camera );
    setState(() {
      sampleVideo = File(pickerFile.path);
      _controller = VideoPlayerController.file(sampleVideo);
      _initializeVideoPlayerFuture = _controller.initialize();
      sampleImage = null;
    });

    
  }

  @override
  void dispose() {
    
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: Text("Thêm bài viết"),
        backgroundColor: Color(0xff09031D),
        centerTitle: true,
      ),

      body: sampleImage == null && sampleVideo == null 
      ? Center(child: Text("Chọn một bức ảnh trạng thái"),)
      
      : Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          reverse: false,
          child: enableUpload(),
        ),
      ),
      
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.deepPurple,
          children: [
            SpeedDialChild(
              child: Icon(Icons.camera_alt),
              label: "Chụp ảnh",
              onTap: getCamera,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            
            SpeedDialChild(
              child: Icon(Icons.image),
              label: "Thư viện ảnh",
              onTap: getImageFromGallery,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            
            SpeedDialChild(
              child: Icon(Icons.videocam),
              label: "Quay video",
              onTap: getVideo,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),

            SpeedDialChild(
              child: Icon(Icons.video_library),
              label: "Thư viện video",
              onTap: getVideoFromGallery,
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ],
        ),
    );
  }


  Widget enableUpload(){
    return Container(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 40,),
              sampleImage != null 
              ? Container(
                width: 400,
                height: 225,
                child: Image.file(sampleImage) ,
              )
              : Container(
                    child: Chewie(
                    controller: ChewieController(
                    videoPlayerController: _controller,
                    aspectRatio: 9/16,
                    autoPlay: false,
                    looping: false,
                  )
                  ),
                ),
              

              !isLoading ? SizedBox(height: 50.0,) : CircularProgressIndicator(),

              TextFormField(
                decoration: new InputDecoration(
                  hintText: "Trạng thái của bạn",
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0)
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSaved: (value){
                  return myValue = value;
                },  
                style: new TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                autofocus: false,      
                ),  
                SizedBox(height: 25.0,), 
                RaisedButton(
                elevation: 5.0,
                child: Text("Đăng trạng thái"),
                textColor: Colors.white,
                color: Colors.black87,
                splashColor: Colors.purple,
                onPressed: sampleImage != null ? uploadStatusImage : uploadStatusVideo,
              ),     
                      ]
                    ),
                    ),
                  
      );
  }
            
           
}