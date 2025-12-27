// Detail Screen with Before/During/After tabs
// ============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/models/disaster_tip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reliefflow_frontend_public_app/env.dart';

class TipDetailScreen extends StatefulWidget {
  final String tipSlug;
  final VoidCallback? onBookmarkChanged;

  const TipDetailScreen({
    super.key,
    required this.tipSlug,
    this.onBookmarkChanged,
  });

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

class _TipDetailScreenState extends State<TipDetailScreen>
    with SingleTickerProviderStateMixin {
  DisasterTipDetail? tipDetail;
  bool isLoading = true;
  late TabController _tabController;
  Set<String> checkedItems = {};

  bool isBookmarked = false;
  bool isLoadingBookmark = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTipDetail();
    _loadCompletedItems();
    _checkBookmarkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        setState(() {
          isLoadingBookmark = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$kBaseUrl/tips/progress'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bookmarks = data['data']['bookmarkedTips'] ?? [];

        setState(() {
          isBookmarked = bookmarks.any((b) => b['slug'] == widget.tipSlug);
          isLoadingBookmark = false;
        });
      }
    } catch (e) {
      print('Error checking bookmark status: $e');
      setState(() {
        isLoadingBookmark = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null || tipDetail == null) return;

      final response = await http.post(
        Uri.parse('$kBaseUrl/tips/bookmark'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'tipId': tipDetail!.id}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool newBookmarkStatus = data['isBookmarked'] ?? false;

        setState(() {
          isBookmarked = newBookmarkStatus;
        });

        if (widget.onBookmarkChanged != null) {
          widget.onBookmarkChanged!();
        }

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

  Future<void> _loadCompletedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) return;

      // Wait for tipDetail to be loaded
      while (tipDetail == null) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      final response = await http.get(
        Uri.parse('$kBaseUrl/tips/completed/${tipDetail!.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> completed = data['data'] ?? [];

        setState(() {
          checkedItems = completed
              .map((item) => item['itemText'].toString())
              .toSet();
        });
      }
    } catch (e) {
      print('Error loading completed items: $e');
    }
  }

  void _toggleCheckItem(String itemText, String phase) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kTokenStorageKey);

    setState(() {
      if (checkedItems.contains(itemText)) {
        checkedItems.remove(itemText);
      } else {
        checkedItems.add(itemText);
      }
    });

    // Save to backend if logged in
    if (token != null && tipDetail != null) {
      try {
        await http.post(
          Uri.parse('$kBaseUrl/tips/checklist'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'tipId': tipDetail!.id,
            'phase': phase,
            'itemText': itemText,
          }),
        );
      } catch (e) {
        print('Error saving checklist item: $e');
      }
    }
  }

  Future<void> _fetchTipDetail() async {
    try {
      final response = await http.get(
        Uri.parse('$kBaseUrl/tips/slug/${widget.tipSlug}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tipDetail = DisasterTipDetail.fromJson(data['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tip detail: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'bg-blue-500':
        return Colors.blue;
      case 'bg-red-500':
        return Colors.red;
      case 'bg-amber-600':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tipDetail == null) {
      return Scaffold(
        body: Center(child: Text('Failed to load tip details')),
      );
    }

    final color = _getColorFromString(tipDetail!.color);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 15,
              left: 15,
              right: 15,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tipDetail!.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            tipDetail!.description,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ADD BOOKMARK BUTTON
                    // IconButton(
                    //   icon: Icon(
                    //     isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: _toggleBookmark,
                    // ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              isScrollable: false,
              tabs: [
                Tab(child: Text('📋 Before', style: TextStyle(fontSize: 13))),
                Tab(child: Text('⚠️ During', style: TextStyle(fontSize: 13))),
                Tab(child: Text('✅ After', style: TextStyle(fontSize: 13))),
              ],
            ),
          ),

          // Tab Content with Emergency Contacts inside
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTipsListWithContacts(tipDetail!.beforeTips, Colors.blue),
                _buildTipsListWithContacts(
                  tipDetail!.duringTips,
                  Colors.orange,
                ),
                _buildTipsListWithContacts(tipDetail!.afterTips, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsListWithContacts(List<TipItem> tips, Color phaseColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // Info Banner
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: phaseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: phaseColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: phaseColor, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tabController.index == 0
                        ? 'Preparation is key - Complete these now'
                        : _tabController.index == 1
                        ? 'Follow these during the emergency'
                        : 'Recovery steps after the emergency',
                    style: TextStyle(
                      fontSize: 13,
                      color: phaseColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tips List
          ...tips.map((tip) {
            final isChecked = checkedItems.contains(tip.text);

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isChecked ? Colors.green[50] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isChecked
                      ? Colors.green
                      : tip.critical
                      ? Colors.red[300]!
                      : Colors.grey[300]!,
                  width: tip.critical ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleCheckItem(
                    tip.text,
                    _tabController.index == 0
                        ? 'before'
                        : _tabController.index == 1
                        ? 'during'
                        : 'after',
                  ),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isChecked
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isChecked ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isChecked
                                      ? Colors.grey[600]
                                      : Colors.black,
                                ),
                              ),
                              if (tip.critical) ...[
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '⚠️ CRITICAL',
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          if (tipDetail!.videos.isNotEmpty) ...[
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.play_circle, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Video Tutorials',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...tipDetail!.videos.map((video) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () async {
                          final Uri videoUri = Uri.parse(video.url);
                          if (await canLaunchUrl(videoUri)) {
                            await launchUrl(
                              videoUri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      video.duration,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.open_in_new,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],

          // Emergency Contacts (at bottom of each tab)
          if (tipDetail!.emergencyContacts.isNotEmpty) ...[
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...tipDetail!.emergencyContacts.map((contact) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _makePhoneCall(contact.number),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  contact.name,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                contact.number,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            SizedBox(height: 15),
          ],
        ],
      ),
    );
  }
}
