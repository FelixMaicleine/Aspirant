import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';

class Verif extends StatefulWidget {
  const Verif({super.key});

  @override
  State<Verif> createState() => _VerifState();
}

class _VerifState extends State<Verif> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    _controllers[5].addListener(() {
      bool allBoxesFilled =
          _controllers.every((controller) => controller.text.isNotEmpty);
      if (allBoxesFilled) {
        Navigator.pushNamed(context, '/change');
      }
    });

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
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 50.0,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index - 1]);
                      }
                    },
                    focusNode: _focusNodes[index],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () {
                if (_controllers
                    .every((controller) => controller.text.isNotEmpty)) {
                  Navigator.pushNamed(context, '/change');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please fill all verification code boxes.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
