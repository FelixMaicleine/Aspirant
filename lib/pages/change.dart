import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:aspirant/services/db_helper.dart';

class Change extends StatefulWidget {
  const Change({super.key});

  @override
  State<Change> createState() => _Change();
}

class _Change extends State<Change> {
  String _username = ''; 
  String _newPasswordErrorText = '';
  String _confirmPasswordErrorText = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isButtonEnabled = false;

  void _showSnackBar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 5) {
      return 'Password must be at least 5 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  void _updateButtonStatus() {
    setState(() {
      _isButtonEnabled = _username.isNotEmpty &&
          _validatePassword(_newPassword) == null &&
          _newPassword == _confirmPassword;
    });
  }

  void _handleChangePassword() async {
    if (_validatePassword(_newPassword) == null && _username.isNotEmpty) {
      if (_newPassword == _confirmPassword) {
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
                    'Changing password...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );

        await Future.delayed(Duration(seconds: 2));

        Navigator.pop(context);

        final dbHelper = DBHelper.instance;
        final rowsAffected =
            await dbHelper.updatePassword(_username, _newPassword);

        if (rowsAffected > 0) {
          _showSnackBar(context, 'Password has been changed successfully', Colors.green);
          Navigator.pushNamedAndRemoveUntil(context, '/', ModalRoute.withName('/'));
        } else {
          _showSnackBar(context, 'Username not found', Colors.red);
        }
      } else {
        _showSnackBar(context, 'Passwords do not match', Colors.red);
      }
    } else {
      _showSnackBar(context, 'Please fill in all fields correctly', Colors.red);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'Username',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _username = value;
                        _updateButtonStatus();
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter your username',
                          prefixIcon: Icon(Icons.person)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'New password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _newPassword = value;
                        _newPasswordErrorText =
                            _validatePassword(value) ?? '';
                        _updateButtonStatus();
                        setState(() {});
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter your new password',
                          prefixIcon: Icon(Icons.lock_outline)),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _newPasswordErrorText,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Confirm new password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _confirmPassword = value;
                        _confirmPasswordErrorText = _newPassword == value
                            ? ''
                            : 'Passwords do not match';
                        _updateButtonStatus();
                        setState(() {});
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Confirm your new password',
                          prefixIcon: Icon(Icons.lock)),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _confirmPasswordErrorText,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _handleChangePassword : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(200, 50)),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Back to'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  Text("/"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.blue),
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
