import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/services/FireStoreService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'models/Chat.dart';
import 'models/Comment.dart';
import 'models/User.dart';

class ChatPage extends StatefulWidget {
  final User user1, user2;
  //final String idChat;

  const ChatPage({Key key, this.user1, this.user2}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatPage();
  }
  
}

class _ChatPage extends State<ChatPage> {

  User user1, user2;
  Chat chat;
  String idChat;
  File mesImage; String urlImg;
  FireStoreService fireStoreService = FireStoreService();
  final Firestore _collectionReference = Firestore.instance;
  final TextEditingController eCtrl = new TextEditingController();
  //List<Comment> messageList;
  @override
  void initState() {

    user1 = this.widget.user1;
    user2 = this.widget.user2;

    Set c1 = Set.from(user1.chats);
    Set c2 = Set.from(user2.chats);

    print(c1.intersection(c2).length);

    if(c1.intersection(c2).length == 0){
      fireStoreService.createChat(Chat(user1.id, user2.id, [])).whenComplete(() {
        fireStoreService.getChat(c1.intersection(c2).single).then((value) {
          setState((){
            chat = value;
            idChat = c1.intersection(c2).single;
          });
        });
      });
    }
    else
    fireStoreService.getChat(c1.intersection(c2).single).then((value) {
      setState((){
        chat = value;
        idChat = c1.intersection(c2).single;
      });
    });

    _collectionReference.collection("chats")
    .snapshots().listen((result) {
      result.documentChanges.forEach( (value) {
        if(value.document.documentID == c1.intersection(c2).single &&
           value.type == DocumentChangeType.modified ) {
          Chat _chat = Chat.fromData(value.document.data);
          if(mounted)
          setState(() {
            chat.messageList.addAll(_chat.messageList.sublist(chat.messageList.length));
          });
        }
       });
    });
    super.initState();
  }

  addMessage(String text) async{
    eCtrl.clear();
    if(mesImage != null) 
      await uploadStatusImage();
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy");
    var formatTime = new DateFormat("EEEE, hh:mm:ss:SS aaa");
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    Comment newMes = Comment(user1.id, text, urlImg, date, time);
    
    fireStoreService.addMessage(idChat, newMes);
  }

  void uploadStatusImage() async{
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Chat message image");
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(mesImage);
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      setState(() {
        urlImg = imageUrl.toString();
        //print(urlImg);
      });
  }

  final picker = ImagePicker();
  void getMessageImage() async {
    final pickerFile = await picker.getImage(imageQuality: 90, source: ImageSource.gallery);
    setState(() {
      mesImage = File(pickerFile.path);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    if(chat != null) 
    {
      List<Comment> messageList = chat.messageList;
      
    return Scaffold(
      appBar: AppBar(
        title: Text(user2.username),
      ),
      body: SingleChildScrollView(
        reverse: false,
        child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 130),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: messageList.length > 0 ? 
            Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: ListView.builder(
                cacheExtent: pow(10, 10).toDouble(),
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  if(messageList[index].id_user == user1.id)
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Text(
                            messageList[index].content,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white
                            )
                            ),
                        ),
                        messageList[index].image != "" ? Container(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Image.network(messageList[index].image, width: 320, height: 180, alignment: Alignment.topRight,) ,
                        ) : SizedBox(height: 0),
                      ],
                    )
                  );

                  else {
                    return 
                    ListTile (
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user2.avatar)
                        ),
                        title: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                                Container(
                                  // margin: EdgeInsets.only(bottom: 8.0),
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Text(
                                    messageList[index].content,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87
                                    )
                                    ),
                                ),
                              messageList[index].image != "" ? Container(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Image.network(
                                  messageList[index].image, 
                                  width: 320, height: 180, 
                                  alignment: Alignment.topLeft,) ,
                              ) : SizedBox(height: 0),
                          ],
                        )
                        ),
                      
                    );
                  }
                },
              ),
          ) : Center(child: Text("Bắt đầu cuộc trò chuyện"),)),
          //SizedBox(height: 10.0),
          Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: 
              TextField(
                style: TextStyle(
                  fontSize: 16
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Nhập tin nhắn",
                  contentPadding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                  prefixIcon: GestureDetector(
                    child: Icon(Icons.image),
                    onTap: getMessageImage,
                  ),
                  
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.send),
                    onTap: (){
                      addMessage(eCtrl.text);
                    },
                  )
                  
                ),
                controller: eCtrl,
                onSubmitted: (value){
                  addMessage(value);
                },
                
              ),  
            ),
      ],
      ) ,
    )
    ));
  }

  else return Center(child: CircularProgressIndicator(),);
  
  }

  

}