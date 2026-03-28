import 'package:flutter/material.dart';
import '../widgets/app_bottom_navbar.dart';
import '../notifications/tab_change_notification.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const TasksPage(),
    const GroupsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return NotificationListener<TabChangeNotification>(
      onNotification: (notification) {
        setState(() => currentIndex = notification.tabIndex);
        return true;
      },
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: AppBottomNavbar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() => currentIndex = index);
          },
        ),
      ),
    );
  }
}
