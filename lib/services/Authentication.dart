import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'FireStoreService.dart';
import '../models/User.dart';

abstract class AuthImplementation{
  Future<String> SignIn(String email, String password);
  Future SignUpWithEmail(
    { String avatar,
      String username, String email, 
      String password, List<String> followingUsers,
      List<String> followedUsers, List<String> postedList,
      List<Notification> notifyList
    }
  );
  Future<String> getCurrentUser();
 
  Future<void> SignOut();
  Future populateCurrentUser();
}

class Auth implements AuthImplementation{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FireStoreService _fireStoreService = FireStoreService();

  
  
  
  Future<String> getCurrentUser() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    if(user != null)
      return user.uid;
    return "";
  } 

  Future populateCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    User _currentUser;
    
      _currentUser = await _fireStoreService.getUser(user.uid);
    
    print(_currentUser);
    return _currentUser;
  }

  Future<String> SignIn(String email, String password) async{
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  Future SignUpWithEmail({
    @required String avatar,
    @required String username,
    @required String email,
    @required String password,
    @required List<String> followingUsers,
    @required List<String> followedUsers,
    @required List<String> postedList,
    List<Notification> notifyList
  }) async{
    try{
      
      var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fireStoreService.createUser(User(
            avatar: avatar,
            id: authResult.user.uid,
            username: username,
            email: email,
            password: password,
            followingUsers: [],
            followedUsers: [],
            postedList: [],
            notifyList: []
           )
      );

      return authResult.user != null;
    }
    catch(e){
      return e.message;
    }
  }

  


  Future<void> SignOut() async{
    return _firebaseAuth.signOut();
  }

}

