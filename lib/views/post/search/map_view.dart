import 'dart:async';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/helpers/map_helper.dart';
import 'package:google_maps_in_flutter/services/geolocation_service.dart';

class PostSearchMapView extends StatefulWidget {
  const PostSearchMapView({Key? key, required this.markers}) : super(key: key);

  final Set<MapMarker> markers;

  @override
  State<PostSearchMapView> createState() => _PostSearchMapViewState();
}

class _PostSearchMapViewState extends State<PostSearchMapView> {
  /// Google Map controller
  late GoogleMapController _controller;

  /// Current device location
  late Position _currentPosition;

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

  /// Markers to be displayed
  Set<MapMarker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    Position pos = await getCurrentPosition();
    final BitmapDescriptor markerImage = await MapHelper.getMarkerImageFromUrl(
        'https://img.icons8.com/material-rounded/24/000000/marker-a.png');
    List<MapMarker> markers = [
      ...widget.markers,
      MapMarker(
        id: 'CURRENT_POSITION',
        position: LatLng(pos.latitude, pos.longitude),
        icon: markerImage,
      )
    ];
    Fluster<MapMarker> clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );
    setState(() {
      _controller = controller;
      _isMapLoading = false;
      _currentPosition = pos;
      _markers = markers.toSet();
      _clusterManager = clusterManager;
      _currentZoom = 5;
      _controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition.latitude, _currentPosition.longitude),
          _currentZoom,
        ),
      );
    });
  }

  void _updateMarkers([double? updatedZoom]) {
    if (updatedZoom == _currentZoom) return;
    setState(() {
      if (updatedZoom != null) _currentZoom = updatedZoom;
      _markers
        ..clear()
        ..addAll(MapHelper.getClusterMarkers(_clusterManager, _currentZoom));
    });
  }

  Future<void> _onCameraMove(CameraPosition? position) async {
    if (position != null) {
      _updateMarkers(position.zoom);
    }
  }

  Future<void> _onTap(LatLng? position) async {
    if (position != null) {
      _controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          position,
          _currentZoom,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onTap: _onTap,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: const LatLng(0, 0),
            zoom: _currentZoom,
          ),
          markers: _markers.map((e) => e.toMarker()).toSet(),
          onCameraMove: _onCameraMove,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
        ),
        // Map loading indicator
        Opacity(
          opacity: _isMapLoading ? 1 : 0,
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
