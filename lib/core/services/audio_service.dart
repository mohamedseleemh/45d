import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  
  AudioService._();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  
  // Stream controllers
  final StreamController<bool> _recordingStateController = 
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingStateController = 
      StreamController<bool>.broadcast();
  final StreamController<Duration> _recordingDurationController = 
      StreamController<Duration>.broadcast();

  // Getters for streams
  Stream<bool> get recordingStateStream => _recordingStateController.stream;
  Stream<bool> get playingStateStream => _playingStateController.stream;
  Stream<Duration> get recordingDurationStream => _recordingDurationController.stream;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  Future<bool> initialize() async {
    try {
      if (!kIsWeb) {
        final microphonePermission = await Permission.microphone.request();
        if (!microphonePermission.isGranted) {
          throw Exception('Microphone permission is required');
        }
      }

      // Setup audio player listeners
      _player.onPlayerStateChanged.listen((state) {
        _isPlaying = state == PlayerState.playing;
        _playingStateController.add(_isPlaying);
      });

      if (kDebugMode) {
        print('✅ Audio service initialized successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Audio service initialization failed: $e');
      }
      return false;
    }
  }

  Future<bool> startRecording({String? outputPath}) async {
    try {
      if (_isRecording) {
        await stopRecording();
      }

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      if (outputPath != null) {
        await _recorder.start(config, path: outputPath);
        _currentRecordingPath = outputPath;
      } else {
        await _recorder.start(config);
      }

      _isRecording = true;
      _recordingStateController.add(_isRecording);

      // Start duration tracking
      _startDurationTracking();

      if (kDebugMode) {
        print('✅ Recording started');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Start recording failed: $e');
      }
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _recorder.stop();
      _isRecording = false;
      _recordingStateController.add(_isRecording);

      if (kDebugMode) {
        print('✅ Recording stopped: $path');
      }

      return path;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stop recording failed: $e');
      }
      return null;
    }
  }

  Future<bool> playAudio(String audioPath) async {
    try {
      if (_isPlaying) {
        await stopPlaying();
      }

      await _player.play(DeviceFileSource(audioPath));
      
      if (kDebugMode) {
        print('✅ Audio playback started: $audioPath');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Audio playback failed: $e');
      }
      return false;
    }
  }

  Future<void> stopPlaying() async {
    try {
      await _player.stop();
      
      if (kDebugMode) {
        print('✅ Audio playback stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stop audio playback failed: $e');
      }
    }
  }

  Future<void> pausePlaying() async {
    try {
      await _player.pause();
      
      if (kDebugMode) {
        print('✅ Audio playback paused');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Pause audio playback failed: $e');
      }
    }
  }

  Future<void> resumePlaying() async {
    try {
      await _player.resume();
      
      if (kDebugMode) {
        print('✅ Audio playback resumed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Resume audio playback failed: $e');
      }
    }
  }

  void _startDurationTracking() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // This is a simplified duration tracking
      // In a real implementation, you'd get the actual recording duration
      _recordingDurationController.add(Duration(seconds: timer.tick));
    });
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await stopRecording();
      }
      
      if (_isPlaying) {
        await stopPlaying();
      }

      await _recorder.dispose();
      await _player.dispose();
      
      await _recordingStateController.close();
      await _playingStateController.close();
      await _recordingDurationController.close();

      if (kDebugMode) {
        print('✅ Audio service disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Audio service disposal failed: $e');
      }
    }
  }
}