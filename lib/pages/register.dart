import 'package:flutter/material.dart';
import 'package:aspirant/services/sqflite_akun.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  void _showSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        'You must fill your email, username, passwords and the terms of service!',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _selectedGender = 'Not Telling';
  final List<String> _genders = ['Not Telling', 'Male', 'Female'];
  IconData _selectedIcon = Icons.person;
  bool _agreedToTerms = false;
  bool _isButtonEnabled = false;
  bool _isObscured1 = true;
  bool _isObscured2=true;

  void _updateSelectedIcon() {
    switch (_selectedGender) {
      case 'Male':
        _selectedIcon = Icons.male;
        break;
      case 'Female':
        _selectedIcon = Icons.female;
        break;
      case 'Not Telling':
        _selectedIcon = Icons.remove;
        break;
      default:
        _selectedIcon = Icons.person;
        break;
    }
  }

  String _usernameErrorText = '';
  String _emailErrorText = '';
  String _passwordErrorText = '';
  String _confirmPasswordErrorText = '';

  void _validateForm() {
    setState(() {
      _emailErrorText = '';
      _usernameErrorText = '';
      _passwordErrorText = '';
      _confirmPasswordErrorText = '';
    });

    bool isUsernameValid = _usernameController.text.isNotEmpty;
    if (!isUsernameValid) {
      setState(() {
        _usernameErrorText = 'Username can`t be empty';
      });
    }
    bool isEmailValid = _emailController.text.isNotEmpty &&
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
            .hasMatch(_emailController.text);
    if (!isEmailValid) {
      setState(() {
        _emailErrorText = 'Invalid email address';
      });
    }

    String passwordPattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{5,}$';
    bool isPasswordValid = _passwordController.text.isNotEmpty &&
        RegExp(passwordPattern).hasMatch(_passwordController.text);
    if (!isPasswordValid) {
      setState(() {
        _passwordErrorText = 'Min 5 characters (upper,lower,digit,special)';
      });
    }

    bool isConfirmPasswordValid = _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;
    if (!isConfirmPasswordValid) {
      setState(() {
        _confirmPasswordErrorText = 'Passwords do not match';
      });
    }

    bool isAgreeChecked = _agreedToTerms;

    setState(() {
      _isButtonEnabled = isEmailValid &&
          isPasswordValid &&
          isConfirmPasswordValid &&
          isAgreeChecked &&
          isUsernameValid;
    });
  }

  void _handleRegister() async {
    String username = _usernameController.text;
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
                'Creating account...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 2));

    try {
      await DBHelper.instance.createUser(
        _usernameController.text,
        _passwordController.text,
        2,
      );

    await FirebaseAnalytics.instance.logEvent(
      name: 'register',
      parameters: {
              'username': username,  
            },
    );

      Navigator.pop(context);

      final snackBar = SnackBar(
        content: Text(
          'Your account has been created successfully. Try logging in with your new account.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context);

      final snackBar = SnackBar(
        content: Text(
          'An error occurred while creating your account. Please try again.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    analytics.logScreenView(
      screenName: 'Register',
      screenClass: 'Register',
    );
    

    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text("Aspirant Fresh"),
          centerTitle: true,
          
          pinned: true,
          floating: false,
        ),
        SliverFillRemaining(
            child: (Container(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                            onChanged: (value) {
                              _validateForm();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter your email',
                              prefixIcon: Icon(
                                Icons.email,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _emailErrorText,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'First Name',
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter your first name',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'Last Name',
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter your last name',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            items: _genders.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue!;
                                _updateSelectedIcon();
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Select gender',
                              prefixIcon: Icon(
                                _selectedIcon,
                              ),
                            ),
                            
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Username',
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
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter your username',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _usernameErrorText,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'Password',
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
                            controller: _passwordController,
                            obscureText: _isObscured1,
                            onChanged: (value) {
                              _validateForm();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter your password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured1
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured1 = !_isObscured1;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _passwordErrorText,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Confirm Password',
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
                            controller: _confirmPasswordController,
                            obscureText: _isObscured2,
                            onChanged: (value) {
                              _validateForm();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Confirm your password',
                              prefixIcon: Icon(
                                Icons.lock,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured2 = !_isObscured2;
                                  });
                                },
                              ),
                            ),
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
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _agreedToTerms = value!;
                              _validateForm();
                            });
                          },
                        ),
                        Text(
                          'I agree to the terms of service',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_isButtonEnabled) {
                          _handleRegister();
                        } else {
                          _showSnackBar(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(200, 50),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        )))
      ],
    ));
  }
}
