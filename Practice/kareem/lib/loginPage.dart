
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kareem/signup.dart';
import 'package:kareem/textField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'clr.dart';
import 'cstmDialog.dart';
import 'home.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
SharedPreferences? prefs;

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late String finalEmail;
  late String finalpassword;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(Colorconst.bgcolor),
      appBar: AppBar(
        title: Text('Login Page'),
        backgroundColor: Colors.black,
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Enter ID and Password to Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            height: 80,
            width: double.infinity,
          ),
          Padding(
              padding: EdgeInsets.all(5.0),
              child: customTextField(
                  context, emailController, 'Enter your Email')),
          Padding(
              padding: EdgeInsets.all(5),
              child: customTextField(
                  context, passwordController, 'Enter Your Password')),
          custombutton(() async {
            try {
              UserCredential userCredential = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text);
              save(context);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('No user found for that email.');
                customDia(context, 'No user Found');
              } else if (e.code == 'wrong-password') {
                print('Wrong password provided for that user.');
                customDia(context, 'No user Found');
              }
            }
          }, 'Login', context),
          SizedBox(
            width: MediaQuery.of(context).size.width * .7,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 30.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/google.png'),
                            fit: BoxFit.cover),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Sign In with Google",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),

                // by onpressed we call the function signup function
                onPressed: () {
                  signInWithGoogle();
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Column(
              children: [
                Text(
                  'Don\'t have an account?',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                ),
                custombutton(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  );
                }, 'Sign Up', context)
              ],
            ),
          )
        ],
      ),
    );
  }

  save(context) async {
    await SharedPreferences.getInstance();
    prefs?.setString('email', emailController.text);
    prefs?.setString('password', passwordController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
