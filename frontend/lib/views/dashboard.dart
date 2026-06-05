import 'package:flutter/material.dart';

import 'package:assignment_2/widgets/appbar.dart';
import 'package:assignment_2/views/report_page.dart';
import 'package:assignment_2/views/homepage.dart';
import 'package:assignment_2/views/profile_page.dart';
import 'package:assignment_2/views/analysis_history_page.dart';
import 'package:assignment_2/views/login_page.dart';

class Dashboard extends StatelessWidget {
  final bool showProfileBanner;
  final bool isGuest;
  const Dashboard({super.key, this.showProfileBanner = false, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _DashboardShell(showProfileBanner: showProfileBanner, isGuest: isGuest),
    );
  }
}

class _DashboardShell extends StatefulWidget {
  final bool showProfileBanner;
  final bool isGuest;
  const _DashboardShell({this.showProfileBanner = false, this.isGuest = false});

  @override
  State<_DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<_DashboardShell> {
  int myCurrentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = <Widget>[
      HomePage(showProfileBanner: widget.showProfileBanner, isGuest: widget.isGuest),
      const AnalysisHistoryPage(),
      const ReportPage(),
      const ProfilePage(),
    ];
  }

  List<BottomNavigationBarItem> _getNavItems(bool isGuest) {
    return <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.history,
          color: isGuest ? Colors.grey : null,
        ),
        label: 'History',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.report,
          color: isGuest ? Colors.grey : null,
        ),
        label: 'Report',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          isGuest ? Icons.login : Icons.person,
          color: isGuest ? Colors.grey : null,
        ),
        label: isGuest ? 'Login' : 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NpraAppBar(),
      body: pages[widget.isGuest ? 0 : myCurrentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: SafeArea(
          top: false,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                items: _getNavItems(widget.isGuest),
                currentIndex: widget.isGuest ? 0 : myCurrentIndex,
                onTap: (int index) {
                  if (widget.isGuest) {
                    if (index > 0) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage(showBackButton: false)),
                      );
                    }
                  } else {
                    setState(() {
                      myCurrentIndex = index;
                    });
                  }
                },
                backgroundColor: const Color(0xFFF2F0F0),
                selectedItemColor: const Color(0xFF1D0CC2),
                unselectedItemColor: const Color(0xFF8A8DA4),
                selectedIconTheme: const IconThemeData(size: 33),
                unselectedIconTheme: const IconThemeData(size: 28),
                selectedFontSize: 12,
                unselectedFontSize: 12,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
