import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class WebRTCService {
  static WebRTCService? _instance;
  static WebRTCService get instance => _instance ??= WebRTCService._();
  
  WebRTCService._();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  
  // Stream controllers for state management
  final StreamController<MediaStream?> _localStreamController = 
      StreamController<MediaStream?>.broadcast();
  final StreamController<Map<String, MediaStream>> _remoteStreamsController = 
      StreamController<Map<String, MediaStream>>.broadcast();
  final StreamController<bool> _connectionStateController = 
      StreamController<bool>.broadcast();

  // Getters for streams
  Stream<MediaStream?> get localStreamStream => _localStreamController.stream;
  Stream<Map<String, MediaStream>> get remoteStreamsStream => _remoteStreamsController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // Configuration
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  Future<bool> initialize() async {
    try {
      // Request permissions
      if (!kIsWeb) {
        final cameraPermission = await Permission.camera.request();
        final microphonePermission = await Permission.microphone.request();
        
        if (!cameraPermission.isGranted || !microphonePermission.isGranted) {
          throw Exception('Camera and microphone permissions are required');
        }
      }

      if (kDebugMode) {
        print('✅ WebRTC service initialized successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ WebRTC initialization failed: $e');
      }
      return false;
    }
  }

  Future<MediaStream?> createLocalStream({
    bool video = true,
    bool audio = true,
  }) async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': audio ? {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        } : false,
        'video': video ? {
          'width': {'min': 640, 'ideal': 1280, 'max': 1920},
          'height': {'min': 480, 'ideal': 720, 'max': 1080},
          'frameRate': {'min': 15, 'ideal': 30, 'max': 60},
          'facingMode': 'user',
        } : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStreamController.add(_localStream);
      
      if (kDebugMode) {
        print('✅ Local stream created successfully');
      }
      
      return _localStream;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create local stream failed: $e');
      }
      return null;
    }
  }

  Future<RTCPeerConnection> createPeerConnection(String peerId) async {
    try {
      final peerConnection = await createPeerConnection(_configuration, _constraints);
      
      peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
        _sendIceCandidate(peerId, candidate);
      };

      peerConnection.onAddStream = (MediaStream stream) {
        _remoteStreams[peerId] = stream;
        _remoteStreamsController.add(Map.from(_remoteStreams));
        
        if (kDebugMode) {
          print('✅ Remote stream added for peer: $peerId');
        }
      };

      peerConnection.onRemoveStream = (MediaStream stream) {
        _remoteStreams.remove(peerId);
        _remoteStreamsController.add(Map.from(_remoteStreams));
        
        if (kDebugMode) {
          print('🔄 Remote stream removed for peer: $peerId');
        }
      };

      peerConnection.onConnectionState = (RTCPeerConnectionState state) {
        _connectionStateController.add(state == RTCPeerConnectionState.RTCPeerConnectionStateConnected);
        
        if (kDebugMode) {
          print('🔄 Connection state changed for $peerId: $state');
        }
      };

      if (_localStream != null) {
        await peerConnection.addStream(_localStream!);
      }

      _peerConnections[peerId] = peerConnection;
      return peerConnection;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create peer connection failed for $peerId: $e');
      }
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer(String peerId) async {
    try {
      final peerConnection = _peerConnections[peerId];
      if (peerConnection == null) {
        throw Exception('Peer connection not found for $peerId');
      }

      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);
      
      if (kDebugMode) {
        print('✅ Offer created for peer: $peerId');
      }
      
      return offer;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create offer failed for $peerId: $e');
      }
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer(String peerId) async {
    try {
      final peerConnection = _peerConnections[peerId];
      if (peerConnection == null) {
        throw Exception('Peer connection not found for $peerId');
      }

      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);
      
      if (kDebugMode) {
        print('✅ Answer created for peer: $peerId');
      }
      
      return answer;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create answer failed for $peerId: $e');
      }
      rethrow;
    }
  }

  Future<void> setRemoteDescription(String peerId, RTCSessionDescription description) async {
    try {
      final peerConnection = _peerConnections[peerId];
      if (peerConnection == null) {
        throw Exception('Peer connection not found for $peerId');
      }

      await peerConnection.setRemoteDescription(description);
      
      if (kDebugMode) {
        print('✅ Remote description set for peer: $peerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Set remote description failed for $peerId: $e');
      }
      rethrow;
    }
  }

  Future<void> addIceCandidate(String peerId, RTCIceCandidate candidate) async {
    try {
      final peerConnection = _peerConnections[peerId];
      if (peerConnection == null) {
        throw Exception('Peer connection not found for $peerId');
      }

      await peerConnection.addCandidate(candidate);
      
      if (kDebugMode) {
        print('✅ ICE candidate added for peer: $peerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Add ICE candidate failed for $peerId: $e');
      }
    }
  }

  Future<void> toggleAudio() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (final track in audioTracks) {
        track.enabled = !track.enabled;
      }
      
      if (kDebugMode) {
        print('🔄 Audio toggled: ${audioTracks.isNotEmpty ? audioTracks.first.enabled : false}');
      }
    }
  }

  Future<void> toggleVideo() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      for (final track in videoTracks) {
        track.enabled = !track.enabled;
      }
      
      if (kDebugMode) {
        print('🔄 Video toggled: ${videoTracks.isNotEmpty ? videoTracks.first.enabled : false}');
      }
    }
  }

  bool get isAudioEnabled {
    if (_localStream == null) return false;
    final audioTracks = _localStream!.getAudioTracks();
    return audioTracks.isNotEmpty && audioTracks.first.enabled;
  }

  bool get isVideoEnabled {
    if (_localStream == null) return false;
    final videoTracks = _localStream!.getVideoTracks();
    return videoTracks.isNotEmpty && videoTracks.first.enabled;
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks.first);
        
        if (kDebugMode) {
          print('🔄 Camera switched');
        }
      }
    }
  }

  void _sendIceCandidate(String peerId, RTCIceCandidate candidate) {
    // This would be implemented with your signaling server
    // For now, we'll just log it
    if (kDebugMode) {
      print('📤 Sending ICE candidate to $peerId: ${candidate.candidate}');
    }
  }

  Future<void> closePeerConnection(String peerId) async {
    try {
      final peerConnection = _peerConnections[peerId];
      if (peerConnection != null) {
        await peerConnection.close();
        _peerConnections.remove(peerId);
        _remoteStreams.remove(peerId);
        _remoteStreamsController.add(Map.from(_remoteStreams));
        
        if (kDebugMode) {
          print('✅ Peer connection closed for: $peerId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Close peer connection failed for $peerId: $e');
      }
    }
  }

  Future<void> dispose() async {
    try {
      // Close all peer connections
      for (final peerId in _peerConnections.keys.toList()) {
        await closePeerConnection(peerId);
      }

      // Stop local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          track.stop();
        });
        await _localStream!.dispose();
        _localStream = null;
      }

      // Close stream controllers
      await _localStreamController.close();
      await _remoteStreamsController.close();
      await _connectionStateController.close();

      if (kDebugMode) {
        print('✅ WebRTC service disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ WebRTC service disposal failed: $e');
      }
    }
  }
}