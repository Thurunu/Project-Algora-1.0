import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_algora_2/widgets/constants.dart';
import 'package:project_algora_2/widgets/password_text_field.dart';
import '../Back/auth_service.dart';
import '../widgets/background_circle.dart';
import '../widgets/my_button.dart';
import '../widgets/my_text.dart';
import '../widgets/my_text_field.dart';
import 'choice.dart';

class SignupScreen extends StatefulWidget {
  final Function()? onTap;
  const SignupScreen(this.onTap, {super.key});

  @override
  State<SignupScreen> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showPassword = false;
  void showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void validateEmail() {
    String email = emailController.text;
    if (email.isEmpty) {
      showSnackBarMessage("Please enter your email address.");
    } else if (!EmailValidator.validate(email, true) ||
        !email.contains('@') ||
        !email.contains('.')) {
      showSnackBarMessage("Please enter a valid email address.");
    } else {
      signUserIn();
    }
  }

  // Function to handle the user sign-up process
  void signUserIn() async {
    try {
      // Check if the passwords match before creating the user account
      if (passwordController.text == confirmPasswordController.text) {
        // Show a loading circle while the sign-up process is ongoing
        showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                width: 200,
                height: 200,
                fit: BoxFit.fill,
              ),
            );
          },
        ).timeout(const Duration(seconds: 1), onTimeout: () => "timeout");
        // Create the user with email and password using FirebaseAuth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Navigate to the Choice screen
        Navigator.push(
          this.context,
          MaterialPageRoute(builder: (context) => Choice()),
        );
      } else if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password Mismatch."),
            ),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      // If there's an error during sign-up, show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(e.code),
            ),
          );
        },
      );
    }
  }

  //Function to handle Google sign in process
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    // Call AuthService.signInWithGoogle() to handle the Google Sign-In process
    UserCredential? userCredential = await AuthService.signInWithGoogle();
    if (userCredential != null) {
      // The user is signed in successfully
      print("Signed in with Google: ${userCredential.user?.displayName}");

      // Navigate to the ChoiceScreen
      Navigator.pushReplacementNamed(context, '/Choice');
    } else {
      // Sign-in was not successful or was cancelled
      print("Sign-in with Google was not successful.");

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in with Google failed. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            children: [
              //Background image add & formatted
              const Padding(
                padding: EdgeInsets.only(top: 150),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: BackgroundCircle(height: 300.0, width: 300.0),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Column(
                      children: [
                         Padding(
                          padding: const EdgeInsets.only(top: 75, bottom: 25),

                          //Headline
                          child: Text("Let's Create an Account",
                          style: kHeadingTextStyle,
                          ),
                        ),

                        //Email Text Box
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: MyTextField(
                            controller: emailController,
                            hintText: 'example@gmail.com',
                            labelText: 'Email',
                            obscureText: false,
                          ),
                        ),

                        //New Password Text Box Section
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: PasswordTextField(
                            controller: passwordController,
                            hintText: 'new password',
                            labelText: 'New Password',
                          ),
                        ),

                        //Confirm Password TextBox Section
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: PasswordTextField(
                            controller: confirmPasswordController,
                            hintText: 'confirm new password',
                            labelText: 'Confirm Password',
                          ),
                        ),

                        //Signup button section
                        SizedBox(
                          height: 65,
                          width: 360,
                          child: MyButton(validateEmail, 'Sign up'),
                        ),
                        //Divider
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.black54,
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: MyText(
                                    text: 'Or Continue With',
                                    size: 12,
                                    color: Colors.black12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.black54,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Google Sign up button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: OutlinedButton(
                                onPressed: () => _handleGoogleSignIn(context),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the border radius
                                  ),
                                  primary: Colors
                                      .white, // Set button background color
                                  side: const BorderSide(
                                      color: Colors.black), // Setborder color
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.asset(
                                        'assets/images/google.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Add spacing between the image and text
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'Continue With Google',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        //Already have an account? Login
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: const Text(
                                  '\tLogin',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
