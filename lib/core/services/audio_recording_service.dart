import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  AudioRecorder? _audioRecorder;

  AudioRecorder get _recorder {
    _audioRecorder ??= AudioRecorder();
    return _audioRecorder!;
  }

  Future<bool> get isRecording async {
    try {
      return await _recorder.isRecording();
    } catch (e) {
      print(' Recording state error: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      // If recorder was disposed before, create/use a valid instance
      final recorder = _recorder;

      final hasPermission =
      await recorder.hasPermission();

      if (!hasPermission) {
        print(' Microphone permission denied');
        return false;
      }

      final directory =
      await getTemporaryDirectory();

      final filePath =
          '${directory.path}/sensibuddy_${DateTime.now().millisecondsSinceEpoch}.wav';

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      print(' Recording started');
      print(' Audio path: $filePath');

      return true;
    } catch (e) {
      print(' Recording start error: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final recorder = _audioRecorder;

      if (recorder == null) {
        print(' Recorder not initialized');
        return null;
      }

      final recording =
      await recorder.isRecording();

      if (!recording) {
        print(' No active recording');
        return null;
      }

      final path =
      await recorder.stop();

      print(' Recording stopped');
      print(' Audio saved: $path');

      return path;
    } catch (e) {
      print(' Recording stop error: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      final recorder = _audioRecorder;

      if (recorder == null) {
        return;
      }

      final recording =
      await recorder.isRecording();

      if (recording) {
        await recorder.cancel();
      }
    } catch (e) {
      print(' Recording cancel error: $e');
    }
  }

  Future<void> dispose() async {
    try {
      final recorder = _audioRecorder;

      if (recorder != null) {
        await recorder.dispose();
        _audioRecorder = null;
      }
    } catch (e) {
      print(' Recorder dispose error: $e');

      _audioRecorder = null;
    }
  }
}