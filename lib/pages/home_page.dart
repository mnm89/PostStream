import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/models/map_marker.dart';

import 'package:google_maps_in_flutter/services/user_service.dart';
import 'package:google_maps_in_flutter/views/post/search/list_view.dart';
import 'package:google_maps_in_flutter/views/post/search/map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _onMarkerButtonPressed() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
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
                onPressed: () {
                  postUserLogout();
                  Navigator.popUntil(context, ModalRoute.withName('login'));
                },
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          body: const TabBarView(
            children: [
              PostSearchMapView(markers: <MapMarker>{}),
              PostSearchListView(),
            ],
          ),
          floatingActionButton: SafeArea(
            minimum: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                heroTag: 'AddPostButton',
                onPressed: _onMarkerButtonPressed,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: const Icon(
                  Icons.add,
                  size: 36.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
