import 'package:bbts_server/screens/bbtm_screens/view/home_page.dart';
import 'package:bbts_server/screens/profile_screen.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = [
    const HomePage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).appColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/home.png",
              color: Theme.of(context).appColors.textSecondary,
              height: 30,
              errorBuilder: (context, e, _) {
                return Icon(
                  Icons.home,
                  size: 30,
                  color: Theme.of(context).appColors.textSecondary,
                );
              },
            ),
            activeIcon: Image.asset(
              "assets/images/home.png",
              color: Theme.of(context).appColors.primary,
              height: 30,
              errorBuilder: (context, e, _) {
                return Icon(
                  Icons.home,
                  size: 30,
                  color: Theme.of(context).appColors.primary,
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/user.png",
              height: 30,
              color: Theme.of(context).appColors.textSecondary,
              errorBuilder: (context, e, _) {
                return Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                  color: Theme.of(context).appColors.textSecondary,
                );
              },
            ),
            activeIcon: Image.asset(
              "assets/images/user.png",
              height: 30,
              color: Theme.of(context).appColors.primary,
              errorBuilder: (context, e, _) {
                return Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                  color: Theme.of(context).appColors.primary,
                );
              },
            ),
            label: 'Me',
          ),
        ],
        backgroundColor: Theme.of(context).appColors.background,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).appColors.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
