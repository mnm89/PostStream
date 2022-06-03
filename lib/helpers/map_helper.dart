import 'dart:async';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:post_stream/components/map_marker.dart';
import 'package:post_stream/helpers/image_helper.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    int minZoom,
    int maxZoom,
  ) async {
    /// Url image used on cluster markers
    final BitmapDescriptor clusterImage =
        await ImageHelper.getMarkerClusterFromAssets();
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
        BaseCluster? cluster,
        double? lng,
        double? lat,
      ) =>
          MapMarker(
        id: cluster!.id.toString(),
        position: LatLng(lat!, lng!),
        icon: clusterImage,
        isCluster: true,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static List<MapMarker> getClusterMarkers(
    Fluster<MapMarker>? clusterManager,
    double currentZoom,
  ) {
    if (clusterManager == null) return [];

    return clusterManager
        .clusters([-180, -85, 180, 85], currentZoom.toInt()).toList();
  }
}
