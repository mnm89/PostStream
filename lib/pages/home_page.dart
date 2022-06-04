import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:post_stream/components/map_marker.dart';
import 'package:post_stream/pages/create_post_page.dart';
import 'package:post_stream/services/geolocation_service.dart';

import 'package:post_stream/services/user_service.dart';
import 'package:post_stream/views/list_view.dart';
import 'package:post_stream/views/map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _onAddButtonPressed() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostPage(),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _onCloseButtonPressed() async {
    await postUserLogout();
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  Future<void> _initPosition() async {
    Position pos = await getCurrentPosition();
    setState(() {
      _isLoading = false;
      _currentPosition = pos;
    });
  }

  /// Current device location
  Position? _currentPosition;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Posts'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.map)),
                  Tab(icon: Icon(Icons.list)),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: _onAddButtonPressed,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: _onCloseButtonPressed,
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            body: TabBarView(
              children: [
                PostSearchMapView(
                  markers: const <MapMarker>{},
                  currentPosition: _currentPosition,
                ),
                const PostSearchListView(),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: _isLoading ? 1 : 0,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
