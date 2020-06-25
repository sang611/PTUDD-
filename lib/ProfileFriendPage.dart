import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/ImagePostedUI.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'models/User.dart';

class ProfileFriendPage extends StatefulWidget {
  final User curUser;
  final User friendUser;

  const ProfileFriendPage({Key key, this.curUser, this.friendUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileFriendPage();
  }
  
}

class _ProfileFriendPage extends State<ProfileFriendPage> {
  bool isFollowed;
  User curUser, friendUser;
  FireStoreService _fireStoreService = FireStoreService();
  final Firestore _collectionReference = Firestore.instance;
  
  @override
  void initState() {
    curUser = this.widget.curUser;
    friendUser = this.widget.friendUser;
    isFollowed = curUser.followingUsers.contains(friendUser.id);

    
    super.initState();
  }

  setUserFollow(String id_user, String id_follow) {
      setState((){
        isFollowed = !isFollowed;
      }) ;
      _fireStoreService.addUserFollowing(id_user, id_follow);
      _fireStoreService.addUserFollowed(id_follow, id_user);

  }

  removeUserFollow(String id_user, String id_follow) {
      setState((){
        isFollowed = !isFollowed;
      }) ;
      _fireStoreService.removeUserFollowing(id_user, id_follow);
      _fireStoreService.removeUserFollowed(id_follow, id_user);
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trang bạn bè",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color(0xff09031D),
        // actions: <Widget>[
        //   Padding(
        //     padding: EdgeInsets.all(8.0),
        //     child: IconButton(
        //       icon: Icon(Icons.more_vert), 
        //       color: Colors.white,
        //       onPressed: _logoutUser,
        //       )
        //   )
        // ],
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
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(friendUser.avatar)
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      friendUser.username,
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
              ),

              

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
                  friendUser.followedUsers.length.toString(),
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
                  friendUser.followingUsers.length.toString(),
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
                Container (
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
                      friendUser.postedList.length.toString() + " bài viết",
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
          (!isFollowed)
                ? FlatButton(
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
                    setUserFollow(curUser.id, friendUser.id);
                  }
                ) : 
                FlatButton(
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
                    removeUserFollow(curUser.id, friendUser.id);
                  }
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
              friendUser.postedList.length,
              (index) {
                return ImagePostedUI(
                  postId: List.from(friendUser.postedList.reversed)[index],
                  curUser: curUser,
                  //index: index
                );
              }
            ),
          )
          )
        ],
      ),  
    );
  }
  
}