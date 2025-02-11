import 'dart:convert';

import 'package:bearlysocial/views/lines/progress_spinner.dart';
import 'package:bearlysocial/constants/design_tokens.dart';
import 'package:bearlysocial/utils/cloud_util.dart';
import 'package:bearlysocial/utils/cam_util.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;

class ProfilePicture extends StatefulWidget {
  final String uid;
  final bool collapsed;

  const ProfilePicture({
    super.key,
    required this.uid,
    this.collapsed = false,
  });

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool _loading = true;
  bool _enableBorder = true;

  late Widget _canvas;

  @override
  void initState() {
    super.initState();

    // DigitalOceanSpacesAPI.downloadProfilePic(
    //   uid: widget.uid,
    // ).then((base64ProfilePic) {
    //   _canvas = SelfieUtility.buildCircularImage(
    //     base64ProfilePic == null
    //         ? null
    //         : img_lib.decodeImage(base64Decode(base64ProfilePic)),
    //   );

    //   if (base64ProfilePic != null) _enableBorder = false;

    //   setState(() {
    //     _loading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.collapsed ? SideSize.medium : SideSize.large,
      height: widget.collapsed ? SideSize.medium : SideSize.large,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: _enableBorder
            ? Border.all(
                width: ThicknessSize.medium,
                color: Theme.of(context).dividerColor,
              )
            : null,
      ),
      child: Center(
        child: _loading ? const ProgressSpinner() : _canvas,
      ),
    );
  }
}
