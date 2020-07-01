import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/NotifyCardUI.dart';
import 'package:flutterapp/services/Authentication.dart';
import 'models/Notify.dart';
import 'models/User.dart';

class NotificationPage extends StatefulWidget {
  //final AuthImplementation auth;
  final User curUser;
  const NotificationPage({ Key key, this.curUser }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NotificationPage();
  }
}

class _NotificationPage extends State<NotificationPage> {
  User curUser = User();
  List<Notify> notifyList = [];
  final Firestore _collectionReference = Firestore.instance;

  @override
  void initState() {
    curUser = this.widget.curUser;
    notifyList = this.widget.curUser.notifyList;

//    widget.auth.populateCurrentUser().then((user){
//      if(mounted)
//      setState(() {
//        curUser = user;
//        notifyList = curUser.notifyList;
//      });
//    });

    // _collectionReference.collection("users")
    // .where("id", isEqualTo: curUser.id)
    // .snapshots().listen((result) {
    //   result.documentChanges.forEach( (value) {
    //     if(value.type == DocumentChangeType.added) {
    //       User updateUser = User.fromData(value.document.data);
    //       setState(() {
    //         notifyList = updateUser.notifyList;
    //       });
    //     }
    //    });
    // });

    // _collectionReference.collection("users")
    // .where("id", isEqualTo: curUser.id)
    // .snapshots().listen((result) {
    //   result.documentChanges.forEach( (value) {
    //     if(value.type == DocumentChangeType.removed) {
    //       User updateUser = User.fromData(value.document.data);
    //       setState(() {
    //         notifyList = updateUser.notifyList;
    //       });
    //     }
    //    });
    // });

    _collectionReference.collection("users")
    .where("id", isEqualTo: curUser.id)
    .snapshots().listen((result) {
      result.documentChanges.forEach( (value) {
        if(value.type == DocumentChangeType.modified &&
          value.document.data['id'] == curUser.id) {
          //print("modified");
          User updateUser = User.fromData(value.document.data);
          if(mounted)
          setState(() {
            notifyList = updateUser.notifyList;
          });
        }
       });
    });

    super.initState();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Thông báo",
        style: TextStyle(
            color: Color(0xff09031D),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: notifyList.length > 0 ?
            ListView.builder
            (
              itemBuilder: (context, index) {
              return NotifyCardUI(notify: List.from(notifyList.reversed)[index], curUser: curUser, scaffoldKey: scaffoldKey);
            },
              itemCount: notifyList.length,
            ) : SizedBox(height: 0)
    );
  }
  
}