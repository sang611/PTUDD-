import 'package:flutter/material.dart';
import 'Mapping.dart';
import 'services/Authentication.dart';
import 'locator.dart';


void main(){
  setupLocator();
  runApp(BlogApp());
}

class BlogApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
	  return new MaterialApp(
		  title: "Social App",

		  theme: new ThemeData(
			  //primarySwatch: Colors.cyan,
        primaryColor: Colors.black
        
		  ),
		  
		  home: MappingPage(auth: Auth(), ),
	  );
  }
  
}
