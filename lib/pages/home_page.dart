import 'dart:async';
import 'dart:developer';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_in_flutter/data/locations.dart' as locations;
import 'package:google_maps_in_flutter/helpers/dialog_helper.dart';
import 'package:google_maps_in_flutter/helpers/map_helper.dart';
import 'package:google_maps_in_flutter/helpers/map_marker.dart';
import 'package:google_maps_in_flutter/services/geolocation_service.dart';
import 'package:google_maps_in_flutter/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  /// Set of displayed markers and cluster markers on the map
  Set<Marker> _markers = {};

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  late Fluster<MapMarker> _clusterManager;

  /// Current map zoom. Initial zoom will be 2,
  double _currentZoom = 2;

  /// Map loading flag
  bool _isMapLoading = true;

  bool _loading = false;
  bool _centered = true;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  void _initMarkers() async {
    final googleOffices = await locations.getGoogleOffices();
    final List<MapMarker> markers = [];
    final BitmapDescriptor markerImage = await MapHelper.getMarkerImageFromUrl(
        'https://img.icons8.com/office/25/000000/marker.png');
    for (final office in googleOffices.offices) {
      markers.add(
        MapMarker(
          id: office.name,
          position: LatLng(office.lat, office.lng),
          icon: markerImage,
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
            onTap: () async {
              await showDialog(
                context: context,
                builder: (_) => ImageDialog(src: office.image),
              );
            },
          ),
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );
    setState(() {
      _markers = markers.map((e) => e.toMarker()).toSet();
    });
    _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  void _updateMarkers([double? updatedZoom]) {
    if (updatedZoom == _currentZoom) return;
    if (updatedZoom != null) _currentZoom = updatedZoom;
    setState(() {
      _loading = true;
    });

    _markers
      ..clear()
      ..addAll(MapHelper.getClusterMarkers(_clusterManager, _currentZoom));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onCameraMove(CameraPosition position) async {
    _updateMarkers(position.zoom);
  }

  Future<void> _onMarkerButtonPressed() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    if (!_centered) {
      (await _controller.future)
          .animateCamera(CameraUpdate.newLatLngZoom(const LatLng(0, 0), 2));
      setState(() {
        _centered = true;
        _loading = false;
      });
    } else {
      final position = await getCurrentPosition();
      inspect(position);
      setState(() {
        _centered = false;
        _loading;
      });
      (await _controller.future).animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 11));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
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
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: const LatLng(0, 0),
                zoom: _currentZoom,
              ),
              markers: _markers,
              onCameraMove: _onCameraMove,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: true,
              zoomControlsEnabled: true,
            ),
            // Map loading indicator
            Opacity(
              opacity: _isMapLoading ? 1 : 0,
              child: const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              )),
            ),
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
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.add,
                      size: 36.0,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
