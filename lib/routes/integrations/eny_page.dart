import "package:camera/camera.dart";
import "package:flow/services/camera.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/camera_page_base.dart";
import "package:flow/widgets/general/rtl_flipper.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyPage extends StatefulWidget {
  const EnyPage({super.key});

  @override
  State<EnyPage> createState() => _EnyPageState();
}

class _EnyPageState extends State<EnyPage> {
  final GlobalKey<CameraPageBaseState> _cameraPageKey =
      GlobalKey<CameraPageBaseState>();

  @override
  Widget build(BuildContext context) {
    return CameraPageBase(
      key: _cameraPageKey,
      children: [
        Positioned(
          top: 20.0,
          left: 20.0,
          right: 20.0,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: context.colorScheme.surface,
                    ),
                    child: RTLFlipper(
                      child: Icon(Symbols.chevron_left_rounded),
                    ),
                  ),
                ),
                SizedBox.shrink(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (CameraService.cameras?.length ?? 0) > 1
                    ? IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(Symbols.switch_camera_rounded),
                      )
                    : Opacity(
                        opacity: 0,
                        child: IgnorePointer(
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.switch_camera_rounded),
                          ),
                        ),
                      ),
                IconButton(
                  onPressed: () {
                    _cameraPageKey.currentState?.controller?.takePicture();
                    setState(() {});
                  },
                  icon: Icon(switch (_cameraPageKey
                      .currentState
                      ?.controller
                      ?.description
                      .lensDirection) {
                    CameraLensDirection.front => Symbols.camera_front_rounded,
                    CameraLensDirection.back => Symbols.camera_rear_rounded,
                    _ => Symbols.camera_rounded,
                  }),
                ),
                IconButton(
                  onPressed: () {
                    _cameraPageKey.currentState?.rotateFlashMode();
                    setState(() {});
                  },
                  icon: Icon(switch (_cameraPageKey.currentState?.flashMode) {
                    FlashMode.auto => Symbols.flash_auto_rounded,
                    FlashMode.always => Symbols.flash_on_rounded,
                    FlashMode.torch => Symbols.flashlight_on_rounded,
                    _ => Symbols.flash_off_rounded,
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
