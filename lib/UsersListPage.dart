import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'UserListCardUI.dart';
import 'services/Authentication.dart';
import 'services/FireStoreService.dart';

import 'models/User.dart';

class UsersListPage extends StatefulWidget{
  final AuthImplementation auth;
  //final  VoidCallback onSignedOut;

  const UsersListPage({Key key, this.auth}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UsersListPage();
  }
  
}

class _UsersListPage extends State<UsersListPage> {
  User curUser;
  final Firestore _collectionReference = Firestore.instance;
    
  @override
  void initState() {
    

    widget.auth.populateCurrentUser().then((user){
      setState(() {
        curUser = user;
      });
    });

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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Tìm kiếm bạn bè"),
        backgroundColor: Color(0xff09031D),
        actions: <Widget>[
          IconButton(
            icon : Icon(Icons.search),
            onPressed: (){
              //   FireStoreService _fireStoreService = FireStoreService();
              //   List<User> users = new List<User>();
              //   _fireStoreService.getAllUsers().then((res){
              //   res.forEach((user){
              //     users.add(User.fromData(user.data));
              //   print(User.fromData(user.data).username);
              //   });
              
              // });
              showSearch(context: context, delegate: DataSearch(curUser));
            },   
          ),
        ]
      ),
      
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  
    final User curUser;
    DataSearch(this.curUser);

    List<User> list = new List<User>();
    
    
    FireStoreService _fireStoreService = FireStoreService();

  

    List<User> getListUsers() {
      List<User> users = new List<User>();
      _fireStoreService.getAllUsers().then((res){
                  res.forEach((user){
                    if(user.data['id'] != curUser.id)
                    users.add(User.fromData(user.data));
                  });
        list = users;
      });
    }

    // setUserFollow(String id_user, String id_follow) {
    //   _fireStoreService.addUserFollowing(id_user, id_follow);
    // }
    
  
  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for appBar
    return [
      IconButton(
        icon : Icon(Icons.clear),
        onPressed: (){
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<User> resultList = new List<User>();
    resultList = query.isEmpty ? [] : list.where((e) => e.username.toLowerCase().contains(query.toLowerCase())).toList(); 
    resultList.sort((a, b) => a.username.compareTo(b.username));
    // show result
    return 
     Scaffold(
             body: ListView.builder(itemBuilder: (context, index)=>
          //   ListTile(
          //   leading: CircleAvatar(
          //     backgroundImage: NetworkImage('https://cdn.iconscout.com/icon/free/png-256/avatar-370-456322.png'),
          //   ),
          //   title: Text(resultList[index].username),
          //   trailing: FlatButton(
          //     child: Text(
          //       "Follow",
          //     ), 
          //     color: Colors.black87,
          //     textColor: Colors.white,
          //     splashColor: Colors.grey,
          //     padding: EdgeInsets.all(1.0),
          //     onPressed: (){
          //       setUserFollow(user_id, resultList[index].id);
          //     }
          //   ),
          // ),
          UserListCardUI(user: resultList[index], curUser: curUser ),
          itemCount: resultList.length,
          ),
      
    )
    ;

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone search
    List<User> resultList = new List<User>();
    getListUsers();
    resultList = query.isEmpty ? [] : list.where((e) => e.username.toLowerCase().contains(query.toLowerCase())).toList(); 
    
    resultList.sort((a, b) => a.username.compareTo(b.username));
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body:  ListView.builder(itemBuilder: (context, index) =>
    //  ListTile(
    //     leading: CircleAvatar(
    //       backgroundImage: NetworkImage('https://cdn.iconscout.com/icon/free/png-256/avatar-370-456322.png'),
    //     ),
    //     title: Text(resultList[index].username),
    //     trailing: FlatButton(
    //       child: Text(
    //         "Follow",
    //       ), 
    //       color: Colors.black87,
    //       textColor: Colors.white,
    //       splashColor: Colors.grey,
    //       padding: EdgeInsets.all(1.0),
    //       onPressed: (){setUserFollow(curUser.id, resultList[index].id);}
    //     ),
    //   ),
      UserListCardUI(user: resultList[index], curUser: curUser ),
      itemCount: resultList.length,
      )
    
    );
  }

}

