
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/control_bar_widget.dart';
import './widgets/participants_list_widget.dart';
import './widgets/text_chat_widget.dart';
import './widgets/top_overlay_widget.dart';
import './widgets/video_grid_widget.dart';
import './widgets/voice_participants_widget.dart';

class RoomInterface extends StatefulWidget {
  const RoomInterface({Key? key}) : super(key: key);

  @override
  State<RoomInterface> createState() => _RoomInterfaceState();
}

class _RoomInterfaceState extends State<RoomInterface>
    with TickerProviderStateMixin {
  // Camera and audio controllers
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  final AudioRecorder _audioRecorder = AudioRecorder();

  // UI state
  bool _isVideoMode = true;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = true;
  bool _isRoomOwner = true;
  bool _showOverlays = true;
  bool _showParticipantsList = false;
  bool _showTextChat = false;
  bool _isRecording = false;

  // Animation controllers
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayAnimation;

  // Room data
  final String _roomName = "غرفة المطورين العرب";
  final String _connectionQuality = "excellent";

  // Mock participants data
  final List<Map<String, dynamic>> _participants = [
    {
      'id': 'user1',
      'name': 'أحمد محمد',
      'avatar':
          'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': false,
      'isVideoEnabled': true,
      'isSpeaking': true,
      'isOwner': false,
    },
    {
      'id': 'user2',
      'name': 'فاطمة علي',
      'avatar':
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': true,
      'isVideoEnabled': false,
      'isSpeaking': false,
      'isOwner': false,
    },
    {
      'id': 'user3',
      'name': 'محمد حسن',
      'avatar':
          'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': false,
      'isVideoEnabled': true,
      'isSpeaking': false,
      'isOwner': false,
    },
    {
      'id': 'user4',
      'name': 'سارة أحمد',
      'avatar':
          'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': false,
      'isVideoEnabled': false,
      'isSpeaking': true,
      'isOwner': false,
    },
  ];

  // Mock chat messages
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'id': 'msg1',
      'senderName': 'أحمد محمد',
      'content': 'مرحباً بالجميع في الغرفة',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
      'isLocal': false,
      'avatar':
          'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400',
    },
    {
      'id': 'msg2',
      'senderName': 'أنت',
      'content': 'أهلاً وسهلاً، كيف الحال؟',
      'timestamp': DateTime.now().subtract(Duration(minutes: 3)),
      'isLocal': true,
      'avatar': null,
    },
    {
      'id': 'msg3',
      'senderName': 'فاطمة علي',
      'content': 'الحمد لله، متحمسة للمناقشة اليوم',
      'timestamp': DateTime.now().subtract(Duration(minutes: 1)),
      'isLocal': false,
      'avatar':
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeCamera();
    _setupAudio();
  }

  void _initializeControllers() {
    _overlayAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    ));

    _overlayAnimationController.forward();

    // Auto-hide overlays after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && _showOverlays) {
        _toggleOverlays();
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission) return;
      }

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
      await _applySettings();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  Future<void> _setupAudio() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await Permission.microphone.request();
        if (!hasPermission.isGranted) return;
      }
    } catch (e) {
      debugPrint('Audio setup error: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
              const RecordConfig(encoder: AudioEncoder.wav),
              path: 'recording.wav');
        } else {
          final dir = await getTemporaryDirectory();
          String path = '${dir.path}/recording.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
        }
        setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      debugPrint('Recording saved to: $path');
    } catch (e) {
      debugPrint('Recording stop error: $e');
    }
  }

  void _toggleOverlays() {
    setState(() {
      _showOverlays = !_showOverlays;
    });

    if (_showOverlays) {
      _overlayAnimationController.forward();
      // Auto-hide after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        if (mounted && _showOverlays) {
          _toggleOverlays();
        }
      });
    } else {
      _overlayAnimationController.reverse();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    if (_isMuted) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _toggleVideoMode() {
    setState(() {
      _isVideoMode = !_isVideoMode;
    });
  }

  void _leaveRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'مغادرة الغرفة',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في مغادرة الغرفة؟',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/room-list');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('مغادرة'),
          ),
        ],
      ),
    );
  }

  void _endRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إنهاء الغرفة',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إنهاء الغرفة؟ سيتم إخراج جميع المشاركين.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/room-list');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('إنهاء الغرفة'),
          ),
        ],
      ),
    );
  }

  void _showParticipants() {
    setState(() {
      _showParticipantsList = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParticipantsListWidget(
        participants: _participants,
        isRoomOwner: _isRoomOwner,
        onMuteParticipant: _muteParticipant,
        onRemoveParticipant: _removeParticipant,
        onPromoteParticipant: _promoteParticipant,
      ),
    ).whenComplete(() {
      setState(() {
        _showParticipantsList = false;
      });
    });
  }

  void _showSettings() {
    Navigator.pushNamed(context, '/room-settings');
  }

  void _muteParticipant(String participantId) {
    setState(() {
      final index = _participants.indexWhere((p) => p['id'] == participantId);
      if (index != -1) {
        _participants[index]['isMuted'] =
            !(_participants[index]['isMuted'] as bool);
      }
    });
  }

  void _removeParticipant(String participantId) {
    setState(() {
      _participants.removeWhere((p) => p['id'] == participantId);
    });
  }

  void _promoteParticipant(String participantId) {
    setState(() {
      final index = _participants.indexWhere((p) => p['id'] == participantId);
      if (index != -1) {
        _participants[index]['isOwner'] = true;
        _isRoomOwner = false;
      }
    });
  }

  void _toggleTextChat() {
    setState(() {
      _showTextChat = !_showTextChat;
    });
  }

  void _sendMessage(String message) {
    setState(() {
      _chatMessages.add({
        'id': 'msg${_chatMessages.length + 1}',
        'senderName': 'أنت',
        'content': message,
        'timestamp': DateTime.now(),
        'isLocal': true,
        'avatar': null,
      });
    });
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    _cameraController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlays,
        child: Stack(
          children: [
            // Main content area
            Positioned.fill(
              child: _isVideoMode
                  ? VideoGridWidget(
                      participants: _participants,
                      isLocalVideoEnabled: _isVideoEnabled,
                      localVideoPath: null,
                    )
                  : VoiceParticipantsWidget(
                      participants: _participants,
                      isLocalMuted: _isMuted,
                    ),
            ),

            // Top overlay
            if (_showOverlays)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _overlayAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -50 * (1 - _overlayAnimation.value)),
                      child: Opacity(
                        opacity: _overlayAnimation.value,
                        child: TopOverlayWidget(
                          roomName: _roomName,
                          participantCount: _participants.length + 1,
                          connectionQuality: _connectionQuality,
                          onBackPressed: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom control bar
            if (_showOverlays)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _overlayAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - _overlayAnimation.value)),
                      child: Opacity(
                        opacity: _overlayAnimation.value,
                        child: ControlBarWidget(
                          isMuted: _isMuted,
                          isVideoEnabled: _isVideoEnabled,
                          isSpeakerOn: _isSpeakerOn,
                          isRoomOwner: _isRoomOwner,
                          onMuteToggle: _toggleMute,
                          onVideoToggle: _toggleVideo,
                          onSpeakerToggle: _toggleSpeaker,
                          onLeaveRoom: _leaveRoom,
                          onShowParticipants: _showParticipants,
                          onShowSettings: _showSettings,
                          onEndRoom: _endRoom,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Text chat overlay
            if (_showTextChat)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: TextChatWidget(
                  messages: _chatMessages,
                  onSendMessage: _sendMessage,
                ),
              ),

            // Floating action buttons
            if (_showOverlays)
              Positioned(
                top: 50.h,
                right: 4.w,
                child: Column(
                  children: [
                    // Video mode toggle
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: _isVideoMode
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.outline,
                      onPressed: _toggleVideoMode,
                      child: CustomIconWidget(
                        iconName:
                            _isVideoMode ? 'videocam' : 'record_voice_over',
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Text chat toggle
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: _showTextChat
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.outline,
                      onPressed: _toggleTextChat,
                      child: CustomIconWidget(
                        iconName: 'chat',
                        color: Colors.white,
                        size: 5.w,
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
}
