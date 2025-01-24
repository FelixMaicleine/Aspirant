import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('roleId');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        height: 190,
                        child: DrawerHeader(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.green.shade900
                                : Colors.green,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 40.0,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 50.0,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _username,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.profil,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.list,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.kelolastok,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/stok');
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.receipt,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.pesanan,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/admordr');
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.show_chart,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.penjualan,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/sales');
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.seting,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/setting');
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.logout,
                  ),
                  onTap: () {
                    logout();
                  },
                ),
              ],
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[900] : Colors.green[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.welcomeadm,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.admin_panel_settings, size: 40),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _DashboardCard(
                    icon: Icons.list,
                    title: AppLocalizations.of(context)!.kelolastok,
                    onTap: () {
                      Navigator.pushNamed(context, '/stok');
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.receipt,
                    title: AppLocalizations.of(context)!.pesanan,
                    onTap: () {
                      Navigator.pushNamed(context, '/admordr');
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.show_chart,
                    title: AppLocalizations.of(context)!.penjualan,
                    onTap: () {
                      Navigator.pushNamed(context, '/sales');
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.settings,
                    title: AppLocalizations.of(context)!.seting,
                    onTap: () {
                      Navigator.pushNamed(context, '/setting');
                    },
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.green[900] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.green,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
