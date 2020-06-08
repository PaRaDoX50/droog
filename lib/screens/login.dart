//import 'package:droogapp/screens/signup.dart';
//import 'package:droogapp/services/auth.dart';
//import 'package:email_validator/email_validator.dart';
//import 'package:flutter/material.dart';
//
//class LogIn extends StatelessWidget {
//  static final String route = "/log_in";
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.white,
//      body: SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            Image.asset("assets/images/login.png"),
//            Text(
//              "LOGIN",
//              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
//            ),
//            LogInForm(),
//          ],
//        ),
//      ),
//    );
//  }
//}
//
//class LogInForm extends StatefulWidget {
//  @override
//  _LogInFormState createState() => _LogInFormState();
//}
//
//class _LogInFormState extends State<LogInForm> {
//  final _formKey = GlobalKey<FormState>();
//  TextEditingController emailController = TextEditingController();
//  TextEditingController passwordController = TextEditingController();
//  AuthService _authService = AuthService();
//
//
//  @override
//  Widget build(BuildContext context) {
//    final availableHeight = MediaQuery.of(context).size.height -
//        MediaQuery.of(context).padding.vertical;
//
//    final emailField = Padding(
//        padding: EdgeInsets.all(8),
//        child: TextFormField(
//          controller: emailController,
//          validator: (value) {
//            if (EmailValidator.validate(value)) {
//              return null;
//            }
//            return "Enter valid Email";
//          },
//          decoration: InputDecoration(
//              prefixIcon: Icon(Icons.email),
//              hintText: "Email",
//              border:
//                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
//              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
//        ));
//
//    final passwordField = Padding(
//      padding: EdgeInsets.all(8),
//      child: TextFormField(
//        controller: passwordController,
//        decoration: InputDecoration(
//            prefixIcon: Icon(Icons.vpn_key),
//            hintText: "Password",
//            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
//            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
//      ),
//    );
//
//    final logInButton = ButtonTheme(
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(10),
//      ),
//      child: Padding(
//        padding: const EdgeInsets.all(16.0),
//        child: Container(
//            height: availableHeight * .06,
//            width: double.infinity,
//            child: RaisedButton(
//              color: Color(0xffdf1d38),
//              child: Text(
//                "Log In",
//                style: TextStyle(
//                  color: Colors.white,
//                ),
//              ),
//              onPressed: () {
//                if (_formKey.currentState.validate()) {}
//              },
//            )),
//      ),
//    );
//
//    final SignUpButton = ButtonTheme(
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(10),
//      ),
//      child: Padding(
//        padding: const EdgeInsets.all(16.0),
//        child: Container(
//            height: availableHeight * .06,
//            width: double.infinity,
//            child: RaisedButton(
//              color: Color(0xff7c2a2a),
//              child: Text(
//                "Sign Up",
//                style: TextStyle(
//                  color: Colors.white,
//                ),
//              ),
//              onPressed: () {
//                Navigator.pushReplacementNamed(context, SignUp.route);
//              },
//            )),
//      ),
//    );
//
//    return Form(
//      key: _formKey,
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          emailField,
//          SizedBox(height: 16,),
//          passwordField,
//          Container(
//              padding: EdgeInsets.only(right: 8),
//              alignment: Alignment.centerRight,
//              width: double.infinity,
//              child: Text(
//                "Forgot your password?",
//                style: TextStyle(fontSize: 13, color: Color(0xff080808)),
//              )),
//          SizedBox(height: 16,),
//          logInButton,
//          SizedBox(height: 8,),
//          Container(
//              padding: EdgeInsets.only(right: 8),
//              alignment: Alignment.center,
//              width: double.infinity,
//              child: Text(
//                "OR",
//                style: TextStyle(fontSize: 20, ),
//              )),
//          SizedBox(height: 8,),
//          SignUpButton,
//
//        ],
//      ),
//    );
//  }
//}
