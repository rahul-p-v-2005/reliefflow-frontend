// Main Tips List Screen
// ============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/disaster_tip.dart';
import 'package:reliefflow_frontend_public_app/screens/tips/tip_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<DisasterTip> tips = [];
  List<DisasterTip> filteredTips = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTips();

    _fetchBookmarks();
  }

  Set<String> bookmarkedTipIds = {};
  bool isLoadingBookmarks = true;

  Future<void> _fetchBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        setState(() {
          isLoadingBookmarks = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$kBaseUrl/tips/bookmarks'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bookmarks = data['data'] ?? [];

        setState(() {
          bookmarkedTipIds = bookmarks.map((b) => b['_id'].toString()).toSet();
          isLoadingBookmarks = false;
        });
      } else {
        setState(() {
          isLoadingBookmarks = false;
        });
      }
    } catch (e) {
      print('Error fetching bookmarks: $e');
      setState(() {
        isLoadingBookmarks = false;
      });
    }
  }

  Future<void> _toggleBookmark(String tipId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to bookmark tips')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('$kBaseUrl/tips/bookmark'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'tipId': tipId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool isBookmarked = data['isBookmarked'] ?? false;

        setState(() {
          if (isBookmarked) {
            bookmarkedTipIds.add(tipId);
          } else {
            bookmarkedTipIds.remove(tipId);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  Future<void> _fetchTips() async {
    try {
      final response = await http.get(
        Uri.parse('$kBaseUrl/tips'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tipsData = data['data'] ?? [];

        setState(() {
          tips = tipsData.map((e) => DisasterTip.fromJson(e)).toList();
          filteredTips = tips;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tips: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterTips(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTips = tips;
      } else {
        filteredTips = tips
            .where(
              (tip) =>
                  tip.title.toLowerCase().contains(query.toLowerCase()) ||
                  tip.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'bg-blue-500':
        return Colors.blue;
      case 'bg-red-500':
        return Colors.red;
      case 'bg-amber-600':
        return Colors.orange;
      case 'bg-green-500':
        return Colors.green;
      case 'bg-indigo-500':
        return Colors.indigo;
      case 'bg-stone-600':
        return Colors.brown;
      case 'bg-purple-500':
        return Colors.purple;
      case 'bg-yellow-500':
        return Colors.yellow[700]!;
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'Droplets':
        return Icons.water_drop;
      case 'Mountain':
        return Icons.landscape;
      case 'Flame':
        return Icons.local_fire_department;
      case 'Wind':
        return Icons.air;
      case 'Activity':
        return Icons.favorite;
      case 'Zap':
        return Icons.flash_on;
      case 'Home':
        return Icons.home;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Stay prepared, stay safe',
                      style: TextStyle(
                        color: Colors.blue[100],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: _filterTips,
                        decoration: InputDecoration(
                          hintText: 'Search for tips...',
                          hintStyle: TextStyle(fontSize: 13),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Emergency Quick Actions
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _quickActionButton(
                            'Call 112',
                            Icons.phone,
                            Colors.red,
                            onPressed: () async {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: '112',
                              );
                              if (await canLaunchUrl(launchUri)) {
                                await launchUrl(launchUri);
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          _quickActionButton(
                            'Call 108 (Ambulance)',
                            Icons.local_hospital,
                            Colors.orange,
                            onPressed: () async {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: '108',
                              );
                              if (await canLaunchUrl(launchUri)) {
                                await launchUrl(launchUri);
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          _quickActionButton(
                            'Call 101 (Fire)',
                            Icons.local_fire_department,
                            Colors.redAccent,
                            onPressed: () async {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: '101',
                              );
                              if (await canLaunchUrl(launchUri)) {
                                await launchUrl(launchUri);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tips List
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredTips.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No tips found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom:
                              25, // Space for floating bottom navigation bar
                        ),
                        itemCount: filteredTips.length,
                        itemBuilder: (context, index) {
                          final tip = filteredTips[index];
                          return _buildTipCard(tip);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionButton(
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(DisasterTip tip) {
    final color = _getColorFromString(tip.color);
    final icon = _getIconFromString(tip.icon);
    final priorityColor = _getPriorityColor(tip.priority);
    final isBookmarked = bookmarkedTipIds.contains(tip.id);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TipDetailScreen(
                  tipSlug: tip.slug,
                  onBookmarkChanged: _fetchBookmarks,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        tip.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tip.priority.toUpperCase(),
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
