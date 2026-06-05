import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:assignment_2/widgets/searchbar.dart';
import 'package:assignment_2/models/action_title.dart' as models;
import 'actionTitle_detail.dart';
import 'login_page.dart';
import 'package:assignment_2/views/product_result.dart';
import 'package:assignment_2/widgets/video.dart';

import 'package:assignment_2/databases/user_db.dart';
import 'package:assignment_2/models/user.dart';
import 'package:assignment_2/views/skin_profile_page.dart';
import 'package:assignment_2/views/chat_history_page.dart';

class HomePage extends StatefulWidget {
  final bool showProfileBanner;
  final bool isGuest;
  const HomePage({super.key, this.showProfileBanner = false, this.isGuest = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkBannerStatus();
  }

  Future<void> _checkBannerStatus() async {
    if (widget.isGuest) {
      setState(() {
        _showBanner = false;
      });
      return;
    }

    if (widget.showProfileBanner) {
      setState(() {
        _showBanner = true;
      });
      return;
    }

    final String? userId = UserDatabase.currentUserId;
    if (userId != null) {
      final User? user = await UserDatabase.getUserLocal(userId);
      if (user != null) {
        if (!user.skinProfile.profileCompleted && user.skinProfile.wizardSkipCount >= 3) {
          if (mounted) {
            setState(() {
              _showBanner = true;
            });
          }
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _SearchSection(isGuest: widget.isGuest),
          if (widget.isGuest)
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFFD54F),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Log In / Sign Up to Unlock Premium Features',
                      style: TextStyle(
                        color: Color(0xFF333752),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Color(0xFF333752), size: 18),
                  ],
                ),
              ),
            ),
          if (_showBanner)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SkinProfilePage(isStandalone: true)),
                ).then((_) => _checkBannerStatus());
              },
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFFD54F),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Complete Your Skin Profile',
                      style: TextStyle(
                        color: Color(0xFF333752),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Color(0xFF333752), size: 18),
                  ],
                ),
              ),
            ),
          // Use Stack here to place the video section at the bottom right
          Expanded(
            child: Stack(
              children: [
                _HomeContent(isGuest: widget.isGuest),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: const NpraVideoSection(),
                ),
                Positioned(
                  right: 20,
                  bottom: 96, // 20 (base) + 60 (video button height) + 16 (spacing)
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: FloatingActionButton(
                      heroTag: 'home-chat-history-fab',
                      backgroundColor: widget.isGuest ? Colors.grey : const Color(0xFF26A69A),
                      shape: const CircleBorder(),
                      onPressed: () {
                        if (widget.isGuest) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChatHistoryPage()),
                          );
                        }
                      },
                      child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  final bool isGuest;
  const _SearchSection({this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1D0CC2),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          NpraSearchBar(
            onSearch: (String query) {
              final String trimmed = query.trim();
              if (trimmed.isEmpty) return;

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProductResultsPage(query: trimmed, isGuest: isGuest),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool isGuest;
  const _HomeContent({this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    final List<models.ActionTile> tiles =
        models.ActionTile.getAllActionTitle();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        children: [
          ...tiles.map((tile) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ActionTileCard(tile: tile),
              )),
        ],
      ),
    );
  }
}

class ActionTileCard extends StatelessWidget {
  const ActionTileCard({super.key, required this.tile});

  final models.ActionTile tile;

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActionTileDetails(tile: tile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tile.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: tile.iconBackground,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: tile.svgAsset != null
                    ? SvgPicture.asset(
                        tile.svgAsset!,
                        width: 26,
                        height: 26,
                        colorFilter: ColorFilter.mode(
                          tile.iconColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        tile.icon,
                        color: tile.iconColor,
                        size: 26,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  tile.title,
                  style: const TextStyle(
                    color: Color(0xFF333752),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8A8DA4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
