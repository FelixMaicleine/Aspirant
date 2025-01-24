import 'package:aspirant/provider/bahasa.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LanguageSettings extends StatefulWidget {
  const LanguageSettings({super.key});

  @override
  _LanguageSettingsState createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  String? _selectedLanguage;
  String? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    _loadSelectedTheme();
  }

  _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('languageCode') ?? 'en';
    });
  }

  _loadSelectedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('themeMode') ?? 'light';
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.bhs,
                      style: TextStyle(fontSize: 18),
                    ),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      onChanged: (String? newValue) async {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                        localeProvider.setLocale(Locale(newValue!));
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString('languageCode', newValue);
                      },
                      items: <String>['en', 'id', 'zh']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'en'
                              ? AppLocalizations.of(context)!.ing
                              : value == 'id'
                                  ? AppLocalizations.of(context)!.ind
                                  : AppLocalizations.of(context)!.mand),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.thm,
                      style: TextStyle(fontSize: 18),
                    ),
                    DropdownButton<String>(
                      value: _selectedTheme,
                      onChanged: (String? newValue) async {
                        setState(() {
                          _selectedTheme = newValue;
                        });
                        if (newValue == 'dark') {
                          themeProvider.toggleTheme(true);
                        } else {
                          themeProvider.toggleTheme(false);
                        }
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString('themeMode', newValue!);
                      },
                      items: <String>['light', 'dark']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'light' ? AppLocalizations.of(context)!.terang : AppLocalizations.of(context)!.gelap,),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
