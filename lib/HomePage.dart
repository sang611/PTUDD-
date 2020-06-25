import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'PostCardUI.dart';
import 'services/Authentication.dart';

import 'models/Post.dart';
import 'models/User.dart';
import 'services/FireStoreService.dart';



class HomePage extends StatefulWidget{
  const HomePage({Key key, this.auth, this.curUser}) : super(key: key);
  
   final AuthImplementation auth;
   final User curUser;
   
  
  @override
  State<StatefulWidget> createState() {
    
    return _HomePage();
  }

}

class _HomePage extends State<HomePage>{
  
  User curUser = new User();
  List<Post> postList = [];
  List<String> followUsers = [];
 
  
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  
  FireStoreService _fireStoreService = FireStoreService();
  DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("Post");
  final Firestore _collectionReference = Firestore.instance;

  @override
  void initState() {
    

	  WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

    // widget.auth.populateCurrentUser().then((user){
    //   if(mounted)
    //   setState(() {
    //     curUser = user;
    //   });
    // });
    curUser = this.widget.curUser;

    
    /*postsRef.once().then((DataSnapshot snap){
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postList.clear();

      for(var individualKey in KEYS){
        Post post = new Post(
          DATA[individualKey]['image'],
          DATA[individualKey]['description'],
          DATA[individualKey]['date'],
          DATA[individualKey]['time'],
          0
        );
        postList.add(post);
      }
      sort(postList);
      setState(() {
        print("Length: $postList.length");
      });
    });*/

    
      
	
    // postsRef.onChildAdded.listen((Event event){
    //     Post newPost = new Post.fromSnapshot(event.snapshot);
    //     widget.auth.populateCurrentUser().then((user){
    //       	curUser = user;
			
    //     setState(() {
    //       followUsers = curUser.followingUsers;
    //       print(followUsers);
    //       print(newPost.user_id);
    //       print(followUsers.contains(newPost.user_id));
    //       if(followUsers.contains(newPost.user_id))
    //       postList.add(newPost);	
    //           });
    //       });
    // });

    // postsRef.onChildChanged.listen((Event e) {
    //   Post oldPost = postList.singleWhere((post) => post.id == e.snapshot.key);
    //   Post updatePost = Post.fromSnapshot(e.snapshot);
    //   if(mounted)
    //   setState(() {
    //     postList[postList.indexOf(oldPost)] = updatePost;
    //   });
    // });
    
    postsRef.onChildRemoved.listen((Event e){
      var oldPost = postList.singleWhere((post) => post.id == e.snapshot.key);
      if(mounted)
      setState(() {
        postList.remove(oldPost);
      });
    });

    


    super.initState();
  }

  void sort(List<Post> postList){
    postList.sort((a, b){
      int order = a.date.compareTo(b.date);
      if(order == 0)
        order = b.time.compareTo(a.time);
        return order;
    }
    );
  }

  

	Future<Null> _refresh() {
    return 
    widget.auth.populateCurrentUser().then((_user) {
			curUser = _user;
			setState(() {
				followUsers = curUser.followingUsers;
				//print(followUsers);
			});
			postList.clear();
      
      DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("Post");

      postsRef.onChildAdded.listen((Event event){
        if(followUsers.contains(event.snapshot.value['user_id']))
        {
          Post newPost = new Post.fromSnapshot(event.snapshot);
          if(mounted)
          setState(() {
            postList.add(newPost);
          });
        }
      });

      
		});
	 }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar
      (
        
        backgroundColor: Colors.white70,
        title: new Text(
          this.curUser.username!=null?this.curUser.username:"Unknown User",
          style: TextStyle(
            color: Colors.black,
          )
          ),
        automaticallyImplyLeading: false,
		actions: <Widget>[
			new IconButton(
			icon: const Icon(Icons.refresh),
			color: Colors.black87,
			tooltip: 'Refresh',
			onPressed: () {
				_refreshIndicatorKey.currentState.show();
      }
	  ),
		],
      ),

      body: RefreshIndicator(
	    key: _refreshIndicatorKey,
    	onRefresh: _refresh,
	  child: new Container
      (
        child: postList.length == 0 ? 
        Center (
          child: Text("Theo dõi bạn bè để cùng chia sẻ trạng thái") 
        ): 
        new ListView.builder(
          cacheExtent: pow(10, 10).toDouble(),
          itemCount: postList.length,
          itemBuilder: (_, index) {
            
            Post post = List.from(postList.reversed)[index];
            return PostCardUI(post: post, curUser: curUser);
          },
        ),
      ),
    )

    )
    ;
  }

  
}