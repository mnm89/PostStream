import 'dart:async';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:post_stream/helpers/image_helper.dart';
import 'package:post_stream/helpers/map_helper.dart';
import 'package:post_stream/components/map_marker.dart';

class PostSearchMapView extends StatefulWidget {
  const PostSearchMapView(
      {Key? key, required this.markers, this.currentPosition})
      : super(key: key);

  final Set<MapMarker> markers;
  final Position? currentPosition;

  @override
  State<PostSearchMapView> createState() => _PostSearchMapViewState();
}

class _PostSearchMapViewState extends State<PostSearchMapView> {
  /// Google Map controller
  late GoogleMapController _controller;

  /// Minimum zoom at which the markers will cluster
  final double _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final double _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  late Fluster<MapMarker> _clusterManager;

  /// Current map zoom. Initial zoom will be 2,
  double _currentZoom = 2;

  /// Markers to be displayed
  Set<MapMarker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    List<MapMarker> markers = [
      ...widget.markers,
    ];
    if (widget.currentPosition != null) {
      final BitmapDescriptor markerImage =
          await ImageHelper.getMarkerAFromAssets();

      markers.add(
        MapMarker(
          id: 'MARKER_A',
          position: LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
          icon: markerImage,
        ),
      );
    }

    Fluster<MapMarker> clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom.toInt(),
      _maxClusterZoom.toInt(),
    );
    setState(() {
      _controller = controller;
      _markers = markers.toSet();
      _clusterManager = clusterManager;
      _currentZoom = 5;
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
            target: widget.currentPosition != null
                ? LatLng(widget.currentPosition!.latitude,
                    widget.currentPosition!.longitude)
                : const LatLng(0, 0),
            zoom: widget.currentPosition != null ? 10 : _currentZoom,
          ),
          markers: _markers.map((e) => e.toMarker()).toSet(),
          onCameraMove: _onCameraMove,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
        ),
      ],
    );
  }
}
