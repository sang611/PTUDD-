import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutterapp/ProfilePage.dart';
import 'package:badges/badges.dart';
import 'NotificationPage.dart';
import 'models/User.dart';
import 'services/Authentication.dart';
import 'HomePage.dart';
import 'PhotoUpload.dart';
import 'UsersListPage.dart';

class MiddlePage extends StatefulWidget {

  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  const MiddlePage({Key key, this.auth, this.onSignedOut}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MiddlePage();
  }
  
}

class _MiddlePage extends State<MiddlePage> {

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
int currentTabIndex = 0;
  

 HomePage homePage = new HomePage();
 UsersListPage usersListPage = new UsersListPage();
 PhotoUploadPage photoUploadPage = new PhotoUploadPage();
 NotificationPage notificationPage = new NotificationPage();
 ProfilePage profilePage = ProfilePage();
 User curUser;
 int notifyNum;
 var theAvatar;

  @override
  void initState() {
    
    

     widget.auth.populateCurrentUser().then((user){
      setState(() {
        curUser = user;
        theAvatar = NetworkImage(curUser.avatar);
        notifyNum = curUser.notifyList.where((element) => !element.seen).length;
      });
    });

    
      photoUploadPage = PhotoUploadPage(
                        auth: widget.auth,
                        //onSignedOut: _logoutUser,
                      );
      homePage = HomePage(
                  auth: this.widget.auth,
                  curUser: curUser,
                );
      usersListPage = UsersListPage(
                  auth: widget.auth,
                  //onSignedOut: widget.onSignedOut
                );
      notificationPage = NotificationPage(
                  auth: widget.auth,
                  //onSignedOut: widget.onSignedOut
                );
      profilePage = ProfilePage(
        auth: widget.auth,
        onSignedOut: widget.onSignedOut
      );

    final Firestore _collectionReference = Firestore.instance;
    _collectionReference.collection("users")
    .snapshots().listen((result) {
      result.documentChanges.forEach( (value) {
        if(value.type == DocumentChangeType.modified && 
          value.document.data['id'] == curUser.id) {
          User updateUser = User.fromData(value.document.data);
          if(mounted)
          setState(() {
            notifyNum = updateUser.notifyList.where((element) => !element.seen).length;
          });
        }
       });
    });
     
    

    super.initState();
  }

  @override
    void didChangeDependencies() {
    if(theAvatar!=null)
    precacheImage(theAvatar.image, context);
    
    super.didChangeDependencies();
  }

  
  void _logoutUser() async{
    try{
      await widget.auth.SignOut();
      widget.onSignedOut();
    }catch(e){
      print(e.toString());
    }
   
  }


  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
      body: new Stack(
        children: <Widget>[
          new Offstage(
            offstage: currentTabIndex!=0,
            child: new TickerMode(enabled: currentTabIndex == 0,
            child: new MaterialApp(home: curUser !=null ? HomePage(
                  auth: this.widget.auth,
                  curUser: curUser,
                ) : Padding(
                  padding: const EdgeInsets.only(left: 80, right: 80, bottom: 40, top: 535),
                  
                          child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                          backgroundColor: Colors.grey[300],
                        )
                      
                )
                ),
            )
          ),
          new Offstage(
            offstage: currentTabIndex!=1,
            child: new TickerMode(enabled: currentTabIndex == 1,
            child: new MaterialApp(home: usersListPage))
          ),
          new Offstage(
            offstage: currentTabIndex!=2,
            child: new TickerMode(enabled: currentTabIndex == 2,
            child: new MaterialApp(home: photoUploadPage))
          ),
          new Offstage(
            offstage: currentTabIndex!=3,
            child: new TickerMode(enabled: currentTabIndex == 3,
            child: new MaterialApp(home: notificationPage)
          ),
          ),
          new Offstage(
            offstage: currentTabIndex!=4,
            child: new TickerMode(enabled: currentTabIndex == 4,
            child: new MaterialApp(home: curUser!=null ? ProfilePage(
                                    auth: widget.auth,
                                    curUser: curUser,
                                    onSignedOut: widget.onSignedOut
                                  ) : Center(child: CircularProgressIndicator(
                                    valueColor:new AlwaysStoppedAnimation<Color>(Colors.black87),
                                    backgroundColor: Colors.grey[300],
                                  ),)) 
          ),
          )
        ],
      )
          
        
        ,
      bottomNavigationBar: new BottomNavigationBar
      (
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: SizedBox(height: 0),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: SizedBox(height: 0),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            title: SizedBox(height: 0),
          ),

          BottomNavigationBarItem(
            icon: notifyNum != null && notifyNum != 0 ? Badge(
              badgeContent: Text(
                notifyNum.toString(),
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              child: Icon(Icons.notifications),
              animationType: BadgeAnimationType.scale,
              badgeColor: Colors.blueAccent
            ) : Icon(Icons.notifications_paused),
            title: SizedBox(height: 0),
          ),

          BottomNavigationBarItem(
            //icon: Icon(Icons.person),
            icon: curUser != null ? CircleAvatar(
              
                    backgroundImage: theAvatar,
                    //backgroundImage: NetworkImage(curUser.avatar),
                    radius: 15.0,
                  ) : CircularProgressIndicator(
                    valueColor:new AlwaysStoppedAnimation<Color>(Colors.black87),
                    backgroundColor: Colors.grey[300],
                  ),
            title: SizedBox(height: 0),
          ),
        ],
        onTap: (index){
          setState(() {
            this.currentTabIndex = index;
          });
        },
        
        currentIndex: currentTabIndex,
      ),
    );
  }
  
  
  
}