import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  void _showSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        'Please use the correct format of email!',
        style: TextStyle(color: Colors.white),
      ),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _email = '';
  bool _isButtonEnabled = false;
  final TextEditingController _emailController = TextEditingController();
  String? _emailErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() {
        _emailErrorText = 'Email cannot be empty';
        _isButtonEnabled = false;
      });
    } else if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(email)) {
      setState(() {
        _emailErrorText = 'Enter a valid email';
        _isButtonEnabled = false;
      });
    } else {
      setState(() {
        _emailErrorText = null;
        _isButtonEnabled = true;
      });
    }
  }

  void _handleSendCode() async {
    if (_emailErrorText == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
                SizedBox(width: 20),
                Text(
                  'Sending code...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );

      await Future.delayed(Duration(seconds: 2));

      Navigator.pop(context);

      Navigator.pushNamed(context, '/verif');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: isDarkMode ? Colors.black : Colors.yellow,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            Text(
              "Forgot Password?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                      hintText: 'Enter your e-mail',
                      errorText: _emailErrorText,
                      prefixIcon: Icon(
                        Icons.email,
                      )),
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                      _isButtonEnabled = _email
                          .isNotEmpty; 
                    });
                    _validateEmail(value);
                  },
                ))
              ],
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (_isButtonEnabled) {
                  _handleSendCode();
                } else {
                  _showSnackBar(context); 
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, minimumSize: Size(200, 50)),
              child: Text(
                'Send Code',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Back to',
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.blue),
                    )),
                Text("/"),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
