import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RoomImageSelectorWidget extends StatefulWidget {
  final Function(String?) onImageSelected;
  final String? initialImage;

  const RoomImageSelectorWidget({
    Key? key,
    required this.onImageSelected,
    this.initialImage,
  }) : super(key: key);

  @override
  State<RoomImageSelectorWidget> createState() =>
      _RoomImageSelectorWidgetState();
}

class _RoomImageSelectorWidgetState extends State<RoomImageSelectorWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImage;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {}

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {}
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showCamera = false;
        });
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      await _cropAndSetImage(photo.path);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropAndSetImage(image.path);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _cropAndSetImage(String imagePath) async {
    if (kIsWeb) {
      setState(() {
        _selectedImagePath = imagePath;
        _showCamera = false;
      });
      widget.onImageSelected(imagePath);
      return;
    }

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'اقتصاص الصورة',
            toolbarColor: AppTheme.lightTheme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'اقتصاص الصورة',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImagePath = croppedFile.path;
          _showCamera = false;
        });
        widget.onImageSelected(croppedFile.path);
      }
    } catch (e) {
      setState(() {
        _selectedImagePath = imagePath;
        _showCamera = false;
      });
      widget.onImageSelected(imagePath);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'اختر مصدر الصورة',
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      if (await _requestCameraPermission()) {
                        setState(() {
                          _showCamera = true;
                        });
                        await _initializeCamera();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'camera_alt',
                            size: 8.w,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'الكاميرا',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'photo_library',
                            size: 8.w,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'المعرض',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera && _isCameraInitialized && _cameraController != null) {
      return Container(
        height: 40.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CameraPreview(_cameraController!),
                ),
              ),
              Positioned(
                bottom: 2.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showCamera = false;
                          _isCameraInitialized = false;
                        });
                        _cameraController?.dispose();
                        _cameraController = null;
                      },
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 3),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _pickFromGallery,
                      icon: CustomIconWidget(
                        iconName: 'photo_library',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة الغرفة',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: _selectedImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? CustomImageWidget(
                            imageUrl: _selectedImagePath!,
                            width: double.infinity,
                            height: 25.h,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_selectedImagePath!),
                            width: double.infinity,
                            height: 25.h,
                            fit: BoxFit.cover,
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'add_a_photo',
                        size: 12.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'اضغط لإضافة صورة',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
