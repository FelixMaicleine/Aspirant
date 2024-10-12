import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:aspirant/services/db_helper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int? _staySignedIn;
  bool _agreedToTerms = false;

  void _showSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleLogin(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (_agreedToTerms) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white)),
                SizedBox(width: 20),
                Text('Logging In...', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );

      await Future.delayed(Duration(seconds: 2));

      final user = await DBHelper.instance.getUser(username, password);

      Navigator.pop(context);

      if (user != null) {
        final role = await DBHelper.instance.getRoleById(user['role_id']);
        if (role != null) {
          if (role['name'] == 'admin') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/homeadmin',
              (route) => false,
            );
          } else if (role['name'] == 'user') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/homeuser',
              (route) => false,
            );
          }
          _showSnackBar(context, 'Login Success as ${role['name']}',
              backgroundColor: Colors.green);
        } else {
          _showSnackBar(context, 'Role not found');
        }
      } else {
        _showSnackBar(context, 'Invalid username or password');
      }
    } else {
      _showSnackBar(context, 'You must agree to the terms of service!');
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
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField('Username', _usernameController, Icons.person),
              SizedBox(height: 10),
              _buildTextField('Password', _passwordController, Icons.lock,
                  obscureText: true),
              SizedBox(height: 10),
              _buildStaySignedIn(),
              _buildTermsCheckbox(),
              ElevatedButton(
                onPressed: () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(200, 50),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: 'Enter your $label',
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }

  Widget _buildStaySignedIn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Stay signed in?'),
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: _staySignedIn,
                  onChanged: (value) {
                    setState(() {
                      _staySignedIn = value;
                    });
                  },
                ),
                Text('Yes'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 0,
                  groupValue: _staySignedIn,
                  onChanged: (value) {
                    setState(() {
                      _staySignedIn = value;
                    });
                  },
                ),
                Text('No'),
              ],
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/forgot');
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreedToTerms = value!;
            });
          },
        ),
        Text('I agree to the terms of service'),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Doesn't have an account yet?"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            'Register',
            style: TextStyle(fontSize: 15.0, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
