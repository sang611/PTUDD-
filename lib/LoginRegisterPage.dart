import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/Authentication.dart';
import 'DialogBox.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginRegisterPage extends StatefulWidget{

  const LoginRegisterPage({Key key, this.auth, this.onSignedIn}) : super(key: key);

  final AuthImplementation auth;
  final VoidCallback onSignedIn;
  
  State<StatefulWidget> createState(){
    return _LoginRegisterPage();
  }
  
}

enum FormType{
  login, register
}

class _LoginRegisterPage extends State<LoginRegisterPage>{
  
  DialogBox dialogBox = new DialogBox();

  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;

  String _email = "";
  String _password = "";
  String _username = "";

  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async{
    if(validateAndSave()){
      try{
        if(_formType == FormType.login){

          await widget.auth.SignIn(_email, _password);
          dialogBox.information(context, "Đăng nhập thành công", "Chia sẻ trạng thái với bạn bè của bạn");
          
        }
        else{
          String _avatar = "https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes.png";
          await widget.auth.SignUpWithEmail(
              avatar: _avatar,
              username: _username,
              email: _email,
              password: _password,
              followingUsers: [],
              followedUsers: [],
              postedList: [],
              notifyList: [],
              chats: [],
            );
            
          dialogBox.information(context,
                               "Tạo tài khoản thành công ", 
                               "Bạn có thể đăng nhập từ bây giờ!");
          
        }
        widget.onSignedIn();
      }catch(e){
        dialogBox.information(context, "Lỗi: ", e.toString());
      }
      
    }
  }

  void moveToRegister(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      
      // appBar: new AppBar
      // (
      //   title: _formType == FormType.login ? Text("Đăng nhập") : Text("Tạo tài khoản"),
      // ),

      body: SingleChildScrollView(
      reverse: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child:  Container(
          margin: EdgeInsets.all(15.0),
          child: new Form(
            key: formKey,
            child: new Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: createInputs() + createBtns(),
            )
          ),
        ),
      ),
      )
    );
  }

  List<Widget> createInputs(){
    return [
      logo(),
      SizedBox(height: 10.0,),
      inputs(),
    ];
  }

  Widget logo(){
    
    return 
      new Container(
      width: 200.0,
      height: 200.0,
      decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          image: new DecorationImage(
            fit: BoxFit.fill,
            image: _formType == FormType.login ? 
                    AssetImage("./imgs/login.png") :
                    AssetImage("./imgs/signup.png")
          )
                 

));
  }

  Widget inputs(){
    
        return 
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              _formType == FormType.register ? 
        TextFormField(
        decoration:  InputDecoration(
              labelText: 'Tên người dùng',
        ),

        validator: (value){
              return value.isEmpty ? "Vui lòng nhập tên người dùng" : null;
        },

        onSaved: (value){
              return _username = value;
        },

        style: new TextStyle(
        fontSize: 20.0,
        height: 1.0,
        color: Colors.black,                  
        ),
      ) : SizedBox(height: 0,),

      SizedBox(height: 10.0,),

      
         new TextFormField(
              decoration: new InputDecoration(
                labelText: 'Email',
              ),

              validator: (value){
                return value.isEmpty ? "Vui lòng nhập email hoặc sđt" : null;
              },

              onSaved: (value){
                return _email = value;
              },

              style: new TextStyle(
              fontSize: 20.0,
              height: 1.0,
              color: Colors.black,                  
              ),
        ),
      

      SizedBox(height: 10.0,),
      
      new TextFormField(
        decoration: new InputDecoration(labelText: 'Mật khẩu'),
        obscureText: true,
        validator: (value){
              return value.isEmpty ? "Vui lòng nhập một mật khẩu" : null;
        },

        onSaved: (value){
              return _password = value;
        },
        style: new TextStyle(
        fontSize: 20.0,
        height: 1.0,
        color: Colors.black,
        ),
      ),

      SizedBox(height: 20.0,),
              ],
              
      )
        ;
    
    
  }

  List<Widget> createBtns(){
    if (_formType == FormType.login){
      return 
      [
      new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
        new RaisedButton(
        child: new Text("Đăng nhập", style: new TextStyle(fontSize: 20.0), ),
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                ),
        color: Colors.blue,
        splashColor: Colors.deepPurple,
        onPressed: validateAndSubmit,
      ),

      new FlatButton(
        child: new Text("Chưa có tài khoản?", style: new TextStyle(fontSize: 15.0), ),
        textColor: Colors.red,
       
         onPressed: moveToRegister,
      )
      ]
      )
    ];
    }
    else {
      return [
      new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new RaisedButton(
        child: new Text("Tạo tài khoản", style: new TextStyle(fontSize: 20.0), ),
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                ),
        color: Colors.blue,
        splashColor: Colors.deepPurple,
        onPressed: validateAndSubmit,
      ),

      new FlatButton(
        child: new Text("Đã có tài khoản? Đăng nhập", style: new TextStyle(fontSize: 15.0), ),
        textColor: Colors.red,
       
         onPressed: moveToLogin,
      )
      ]
      )
    ];
    }
  }
}