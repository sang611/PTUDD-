import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/models/Chat.dart';
import 'package:flutterapp/models/Comment.dart';
import 'package:flutterapp/models/Notify.dart';
import 'package:flutterapp/models/Post.dart';
import '../models/User.dart';

class FireStoreService {
  
  final Firestore _collectionReference = Firestore.instance;

  Future createUser(User user) async {
      try {
        await _collectionReference.collection("users").document(user.id).setData(user.toJSON());
        print("added");
      } catch (e) {
        return e.message;
      }
  }

  Future getAllUsers() async {
        List listUsers;
        await _collectionReference.collection("users").getDocuments().then((querySnapshot){
          listUsers = querySnapshot.documents;
        });
      return listUsers;
  }

  Future getUser(String uid) async {
    try {
      var userData = await _collectionReference.collection("users").document(uid).get();
      return User.fromData(userData.data);
    } catch (e) {
      return e.message;
    }
  }


  Future addUserFollowing(String id_user, String id_follow) async {
    try {
      await _collectionReference.collection("users").document(id_user)
            .updateData({ 'followingUsers': FieldValue.arrayUnion([id_follow]) });
    } catch(e) {
      return e.message;
    }
  }

  Future removeUserFollowing(String id_user, String id_follow) async {
    try {
      await _collectionReference.collection("users").document(id_user)
            .updateData({ 'followingUsers': FieldValue.arrayRemove([id_follow]) });
    } catch(e) {
      return e.message;
    }
  }

  Future addUserFollowed(String id_user, String id_follow) async {
    try {
      await _collectionReference.collection("users").document(id_user)
            .updateData({'followedUsers': FieldValue.arrayUnion([id_follow]) });
    } catch(e) {
      return e.message;
    }
  }

  Future removeUserFollowed(String id_user, String id_follow) async {
    try {
      await _collectionReference.collection("users").document(id_user)
            .updateData({'followedUsers': FieldValue.arrayRemove([id_follow]) });
    } catch(e) {
      return e.message;
    }
  }

  Future addPostedList(String id_user, String url) async {
    try {
      await _collectionReference.collection("users").document(id_user)
            .updateData({'postedList': FieldValue.arrayUnion([url])});
    } catch(e) {
      return e.message;
    }
  }

  Future addNotifyList(String id_user, Notify notify) async {
    
    try {
      await _collectionReference.collection("users").document(id_user)
            .updateData({'notifyList': FieldValue.arrayUnion([notify.toJSON()]) });
    } catch(e) {
      return e.message;
    }
  }

  Future updateNotifyList(String id_user, Notify notify) async {
    Notify _notify = notify;
    //_notify.seen = false;

    await _collectionReference.collection("users").document(id_user).get().then((value){
      User user = User.fromData(value.data);
      int index = user.notifyList.indexWhere(
        (element) => element.time == notify.time &&
                     element.idUserA == notify.idUserA &&
                     element.idUserB == notify.idUserB
      );
      user.notifyList.elementAt(index).seen = true;
      _collectionReference.collection("users").document(id_user)
      .updateData({'notifyList': user.notifyList.map((e) => e.toJSON()).toList() });
    });
  }




  // Future createPost(Post post) async {
  //     try {
  //       await _collectionReference.collection("posts").add(post.toJSON());
  //       print("added");
  //     } catch (e) {
  //       return e.message;
  //     }
  // }

  // Future getAllPosts(List<String> followingUsers) async {
  //       List listPosts;
  //       await _collectionReference.collection("posts").getDocuments().then((querySnapshot){
  //         listPosts = querySnapshot.documents.map((snapshot) => Post.fromData(snapshot.documentID, snapshot.data))
  //         .where((mappedItem) => followingUsers.contains(mappedItem.user_id)).toList();
  //       });
  //     return listPosts;
  // }

  Future<String> createChat(Chat chat) async {
      try {
        String idChat;
        await _collectionReference.collection("chats").add(chat.toJSON()).then((value) async {
          await _collectionReference.collection("users")
          .document(chat.idUser1)
          .updateData({ 'chats': FieldValue.arrayUnion([value.documentID]) });

          await _collectionReference.collection("users")
          .document(chat.idUser2)
          .updateData({ 'chats': FieldValue.arrayUnion([value.documentID]) });

          idChat = value.documentID;
        });
        return idChat;
        //print("added");
      } catch (e) {
        return e.message;
      }
  }

  Future addMessage(String idChat, Comment mes) async {
    try {
      await _collectionReference.collection("chats").document(idChat)
            .updateData({'messageList': FieldValue.arrayUnion([mes.toJSON()])});
    } catch(e) {
      return e.message;
    }
  }

  Future getChat(String idChat) async {
    try {
      var chatData = await _collectionReference.collection("chats").document(idChat).get();
      return Chat.fromData(chatData.data);
    } catch (e) {
      return e.message;
    }
  }
  
  Future setLike(Post post) async {
    print(post.id);
    try {
      await _collectionReference.collection("posts").document(post.id)
            .updateData({'like': post.like });
    } catch(e) {
      return e.message;
    }
  }

  Future setUserAvatar(User user, String url) async {
    try {
      await _collectionReference.collection("users").document(user.id)
            .updateData({'avatar': url });
    } catch(e) {
      return e.message;
    }
  }
}
  
  