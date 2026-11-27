import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class ZoomablePhoto extends StatefulWidget {
  const ZoomablePhoto({super.key, required this.url, this.onZoomChanged});

  final String url;
  // Signale le zoom au pager, bloqué tant que la photo est agrandie.
  final ValueChanged<bool>? onZoomChanged;

  @override
  State<ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<ZoomablePhoto> {
  final _transformation = TransformationController();
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transformation.addListener(_onTransform);
  }

  void _onTransform() {
    final zoomed = _transformation.value.getMaxScaleOnAxis() > 1;
    if (zoomed == _zoomed) return;
    _zoomed = zoomed;
    widget.onZoomChanged?.call(zoomed);
  }

  @override
  void dispose() {
    _transformation.removeListener(_onTransform);
    _transformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme.colors;
    final icon = Center(
      child: Icon(Icons.image_outlined, color: colors.onInverse),
    );
    return InteractiveViewer(
      transformationController: _transformation,
      maxScale: 4,
      child: CachedNetworkImage(
        imageUrl: widget.url,
        fit: BoxFit.contain,
        placeholder: (_, _) => icon,
        errorWidget: (_, _, _) => icon,
      ),
    );
  }
}
