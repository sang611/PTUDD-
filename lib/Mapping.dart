import 'package:flutter/material.dart';
import 'package:flutterapp/MiddlePage.dart';
import 'LoginRegisterPage.dart';
import 'services/Authentication.dart';

class MappingPage extends StatefulWidget{
  
  const MappingPage({Key key, this.auth}) : super(key: key);
  
  final AuthImplementation auth;

  @override
  State<StatefulWidget> createState() {
    return _MappingPageState();
  }
  
}

enum AuthStatus{
  signedIn, unsignedIn
}

class _MappingPageState extends State<MappingPage>{
  
  AuthStatus authStatus = AuthStatus.unsignedIn;
  String userId;
  

  @override
  void initState() {
    super.initState();
    
    widget.auth.getCurrentUser().then((firebaseUserId){
      if(firebaseUserId != "")
        setState((){
          authStatus = firebaseUserId == null ? AuthStatus.unsignedIn : AuthStatus.signedIn;
        });
      
    });
  }

  void _signedIn(){
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut(){
    setState(() {
      authStatus = AuthStatus.unsignedIn;
    });

    
  }

  @override
  Widget build(BuildContext context) {
    switch(authStatus){
      case AuthStatus.unsignedIn:
        return new LoginRegisterPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return new MiddlePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
        );
    }
  }
  
}