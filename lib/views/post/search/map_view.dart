import 'dart:async';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/helpers/map_helper.dart';
import 'package:google_maps_in_flutter/models/map_marker.dart';

class PostSearchMapView extends StatefulWidget {
  const PostSearchMapView({Key? key, required this.markers}) : super(key: key);

  final Set<MapMarker> markers;

  @override
  State<PostSearchMapView> createState() => _PostSearchMapViewState();
}

class _PostSearchMapViewState extends State<PostSearchMapView> {
  final Completer<GoogleMapController> _controller = Completer();

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
  final bool _centered = true;

  get markers => null;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  void _initMarkers() async {
    final BitmapDescriptor markerImage = await MapHelper.getMarkerImageFromUrl(
        'https://img.icons8.com/office/25/000000/marker.png');
    _clusterManager = await MapHelper.initClusterManager(
      widget.markers.toList(),
      _minClusterZoom,
      _maxClusterZoom,
    );
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

    // widget.markers
    //   ..clear()
    //   ..addAll(MapHelper.getClusterMarkers(_clusterManager, _currentZoom));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onCameraMove(CameraPosition position) async {
    _updateMarkers(position.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: const LatLng(0, 0),
            zoom: _currentZoom,
          ),
          markers: widget.markers.map((e) => e.toMarker()).toSet(),
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
          )),
        ),
      ],
    );
  }
}
