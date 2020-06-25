import 'package:flutter/material.dart';
import 'PostCardUI.dart';
import 'models/User.dart';
import 'models/Post.dart';

class PostPersonalPage extends StatefulWidget {
  final Post post;
  final User curUser;

  const PostPersonalPage({Key key, this.post, this.curUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PostPersonalPage();
  }
}

class _PostPersonalPage extends State<PostPersonalPage> {

  @override
  void initState() {
   
    super.initState();
    print(this.widget.post.id);

  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: PostCardUI(post: this.widget.post, curUser: this.widget.curUser)
      )
    );
  }
  
}