import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dictionary_app/loginpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dictionary_app/app_theme.dart';
import 'package:dictionary_app/theme_provider.dart';

class OpenDrawer extends StatelessWidget {
  const OpenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final drawerBackgroundColor = themeProvider.isDarkMode ? const Color(0xFF14181B) : Colors.white;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final iconColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final dialogBackgroundColor = themeProvider.isDarkMode ? const Color(0xFF2D4A8A) : Colors.grey.shade200;


    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: width*0.3 ,
            child: const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'WordQuest Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Help
          _buildDrawerButton(context, Icons.help_outline, "Help", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Help tapped")),
            );
          }, textColor , iconColor),

          // Settings
          _buildDrawerButton(context, Icons.settings, "Settings", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings tapped")),
            );
          }, textColor, iconColor),

          // Logout
          _buildDrawerButton(context, Icons.logout, "Logout", () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2D4A8A),
                title: const Text(
                  "Confirm Logout",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).pop(); // close drawer
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text("Logout",
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          }, textColor, iconColor),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, IconData icon,
      String title, VoidCallback onTap, Color textColor, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style:  TextStyle(
              color: textColor, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
