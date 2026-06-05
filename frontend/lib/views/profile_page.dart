import 'package:flutter/material.dart';

import '../databases/user_db.dart';
import '../models/profile.dart';
import '../models/user.dart';
import 'profile_detail.dart';
import 'login_page.dart';
import '../databases/analysis_cache_db.dart';
import '../databases/chat_db.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final String? currentId = UserDatabase.currentUserId;
    if (currentId != null) {
      // 1. Fast load from local SQLite
      final User? localUser = await UserDatabase.getUserLocal(currentId);
      if (mounted && localUser != null) {
        setState(() {
          _currentUser = localUser;
        });
      }
    }

    // 2. Silent background fetch from Supabase (also updates local SQLite internally)
    final User? remoteUser = await UserDatabase.getCurrentUser();
    if (!mounted) return;

    if (remoteUser != null) {
      setState(() {
        _currentUser = remoteUser;
      });
    }
  }

  Future<void> _handleOptionTap(ProfileOption option) async {
    if (option.pageIndex != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ProfileDetails(option: option),
        ),
      );
      await _loadCurrentUser();
      return;
    }

    if (option.name == 'Log out') {
      final String? result = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(option.name),
            content: Text(option.description),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (result == 'OK') {
        await UserDatabase.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
      return;
    }

    if (option.name == 'Clear Cache & History') {
      final String? result = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(option.name),
            content: Text(option.description),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'OK'),
                child: const Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (result == 'OK') {
        await AnalysisCacheDb.instance.clearAll();
        await ChatDb.instance.clearAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache and history cleared successfully')),
          );
        }
      }
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(option.name),
          content: Text(option.description),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProfileOption> options = ProfileOption.getAllOption();

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Container(color: const Color(0xFF1D0CC2)),
          
          Positioned.fill(
            top: 200,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
          
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: _ProfileHeader(user: _currentUser),
              ),

              // Profile Options (Scrollable List)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  itemCount: options.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 16);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final ProfileOption option = options[index];
                    return _ProfileOptionCard(
                      option: option,
                      onTap: () => _handleOptionTap(option),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final String username = user?.username ?? 'Username';
    final String email = user?.email ?? 'hello@gmail.com';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: Color(0xFF1D0CC2),
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(
            color: Color(0xFFE4E6FF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ProfileOptionCard extends StatelessWidget {
  const _ProfileOptionCard({required this.option, required this.onTap});

  final ProfileOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                option.name,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8A8DA4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}