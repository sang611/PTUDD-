import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/services/Authentication.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'package:image_picker/image_picker.dart';

import 'ImagePostedUI.dart';
import 'models/Post.dart';
import 'models/User.dart';
class ProfilePage extends StatefulWidget{
  final AuthImplementation auth;
  final User curUser;
  final  VoidCallback onSignedOut;
  const ProfilePage({Key key, this.auth, this.curUser, this.onSignedOut}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return _ProfilePage();
  }

}

class _ProfilePage extends State<ProfilePage> {

  User curUser = User();
  File avatarImage;
  String url;
  final Firestore _collectionReference = Firestore.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  List<Post> listPost = [];
  @override
  void initState() {
    
    

    // widget.auth.populateCurrentUser().then((user){
    //   if(mounted)
    //   setState(() {
    //     curUser = user;
    //   });
    // });

    curUser = this.widget.curUser;




    // Cloud firestore realtime update
    _collectionReference.collection("users")
    .snapshots().listen((result) {
      result.documentChanges.forEach( (value) {
        if(value.type == DocumentChangeType.modified && 
          value.document.data['id'] == curUser.id) {
          User updateUser = User.fromData(value.document.data);
          if(mounted)
          setState(() {
            curUser = updateUser;
            //curUser.postedList.forEach((element) {print(element);});
          });
          
        }
       });
    });

    super.initState();
  }

  void uploadStatusAvatar() async{
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Avatar");
      var timeKey = new DateTime.now();

      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(avatarImage);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      setState(() {
        url = imageUrl.toString();
        curUser.avatar = url;
      });

      if(url != null)
      {
        FireStoreService fireStoreService = FireStoreService();
        fireStoreService.setUserAvatar(curUser, url);
      }
      
    
  }

  final picker = ImagePicker();
  
  void getAvatarFromGallery() async {
    final pickerFile = await picker.getImage(imageQuality: 90, source: ImageSource.gallery);
    setState(() {
      avatarImage = File(pickerFile.path);
    });

    uploadStatusAvatar();
  }

  void getAvatarFromCamera() async {
    final pickerFile = await picker.getImage(imageQuality: 90, source: ImageSource.camera);
    setState(() {
      avatarImage = File(pickerFile.path);
    });

    uploadStatusAvatar();
  }
  
  

  void _logoutUser() async{
    try{
      await widget.auth.SignOut();
      widget.onSignedOut();
    }catch(e){
      print(e.toString());
    }
   
  }

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Trang cá nhân",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color(0xff09031D),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.more_vert), 
              color: Colors.white,
              onPressed: _logoutUser,
              )
          )
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row( 
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 7),
                child: GestureDetector(
                  onTap: () {
                    scaffoldKey.currentState
                    .showBottomSheet((context) => Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new RaisedButton(
                            child: new Text("Chọn từ thư viện", style: new TextStyle(fontSize: 20.0), ),
                            textColor: Colors.black,
                            color: Colors.white,
                            splashColor: Colors.grey,
                            onPressed: getAvatarFromGallery,
                          ),
                          new RaisedButton(
                            child: new Text("Chụp ảnh", style: new TextStyle(fontSize: 20.0), ),
                            textColor: Colors.black,
                            color: Colors.white,
                            splashColor: Colors.grey,
                            onPressed: getAvatarFromCamera,
                          ),
                        ],
                      ),
                    ));
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(curUser.avatar)
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      curUser.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 17
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Hanoi',
                              style: TextStyle(
                                color: Colors.black,
                                wordSpacing: 2,
                                letterSpacing: 4
                              )
                            ),
                          )
                        ],
                      ),
                    )
                ],),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20.0, left: 20.0, bottom: 12, top: 15
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                  curUser.followedUsers.length.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize:25,
                  ),
                ),
                Text(
                  'người theo dõi'
                ),
                
                ],
                ),

                Container(
                  color: Colors.black,
                  width: 0.2,
                  height: 22,
                  margin: const EdgeInsets.only(
                    left: 12.0, right: 12.0
                  ),
                ),

                Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                  curUser.followingUsers.length.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize:25,
                  ),
                ),
                Text(
                  'đang theo dõi'
                ),
                ],
                ),

              Container(
                  color: Colors.black,
                  width: 0.2,
                  height: 22,
                  margin: const EdgeInsets.only(
                    left: 12.0, right: 12.0
                  ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 0.0, right: 0.0, bottom: 0, top: 0
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff6D0EB5), Color(0xff4059F1)],
                      begin: Alignment.bottomRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(33))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      curUser.postedList.length.toString() + " bài viết",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                  )
                ),
              )
              ],
            ),
          ),
          Container(
                  color: Colors.grey,
                  width: 300,
                  height: 1,
                  margin: const EdgeInsets.only(
                    top: 12.0, bottom: 25.0
                  ),
              ),
          Expanded(
          child: GridView.count(
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            crossAxisCount: 3,
            children: List.generate(
              curUser.postedList.length,
              (index) {
                //print(curUser.postedList[index]);
                return ImagePostedUI(
                  postId: List.from(curUser.postedList.reversed)[index],
                  curUser: curUser,
                );
              }
            ),
          )
          ) //: SizedBox(height: 0)
        ],
      ),  
    );
  }
  
}
