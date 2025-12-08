import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/tts_service.dart';
import '../services/gemini_service.dart';
import '../providers/voice_provider.dart';

class ExerciseScreen extends StatefulWidget {
  final int durationMinutes;

  const ExerciseScreen({super.key, required this.durationMinutes});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> 
    with TickerProviderStateMixin {
  
  late DateTime _startTime;
  late DateTime _endTime;
  bool _isActive = false;
  bool _isCompleted = false;
  bool _isPaused = false;
  int _currentStepIndex = 0;
  
  final ElevenLabsTTSService _ttsService = ElevenLabsTTSService();
  final GeminiContentService _contentService = GeminiContentService();
  List<Map<String, dynamic>> _guidanceSteps = [];
  
  late AnimationController _breathingAnimationController;
  late AnimationController _progressAnimationController;
  Timer? _sessionTimer;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _endTime = _startTime.add(Duration(minutes: widget.durationMinutes));
    
    _breathingAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: Duration(minutes: widget.durationMinutes),
      vsync: this,
    );
    
    // Generate dynamic content and start session
    _setupSession();
  }

  /// Generate unique guidance content and start the session  
  Future<void> _setupSession() async {
    // Show loading state while generating content
    setState(() {
      _isActive = false;
    });

    // Generate unique guidance for this session
    _guidanceSteps = await _contentService.generateBreathingGuidance(widget.durationMinutes);
    
    // Start the exercise after content is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startExercise();
    });
  }
  
  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathingAnimationController.dispose();
    _progressAnimationController.dispose();
    _ttsService.dispose();
    super.dispose();
  }
  
  void _startExercise() async {
    setState(() {
      _isActive = true;
      _isPaused = false;
    });
    
    _breathingAnimationController.repeat(reverse: true);
    _progressAnimationController.forward();
    
    // Start the main session timer
    _sessionTimer = Timer(Duration(minutes: widget.durationMinutes), () {
      if (mounted) {
        _completeExercise();
      }
    });
    
    // Begin guidance
    await _playGuidanceSequence();
  }
  
  void _pauseExercise() async {
    setState(() {
      _isPaused = true;
      _isActive = false;
    });
    
    _breathingAnimationController.stop();
    _progressAnimationController.stop();
    _sessionTimer?.cancel();
    await _ttsService.stop();
  }
  
  void _resumeExercise() {
    setState(() {
      _isPaused = false;
      _isActive = true;
    });
    
    _breathingAnimationController.repeat(reverse: true);
    
    // Calculate remaining time and restart timer
    final now = DateTime.now();
    final remaining = _endTime.difference(now);
    
    if (!remaining.isNegative) {
      _progressAnimationController.forward();
      _sessionTimer = Timer(remaining, () {
        if (mounted) {
          _completeExercise();
        }
      });
    } else {
      _completeExercise();
    }
  }
  
  void _stopExercise() {
    _showExitDialog();
  }
  
  void _completeExercise() async {
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });
    
    _breathingAnimationController.stop();
    _sessionTimer?.cancel();
    
    final voiceId = context.read<VoiceProvider>().selectedVoiceId;
    await _ttsService.speakText(
      "Your Buteyko breathing session is now complete. Take a moment to notice the beautiful warmth and peace flowing through your body. You have given yourself a precious gift of healing. Well done.",
      voiceId,
    );
  }
  
  Future<void> _playGuidanceSequence() async {
    for (int i = 0; i < _guidanceSteps.length && _isActive; i++) {
      if (!mounted) break;
      
      setState(() {
        _currentStepIndex = i;
      });
      
      final step = _guidanceSteps[i];
      
      final voiceId = context.read<VoiceProvider>().selectedVoiceId;
      // Speak the guidance text
      bool success = await _ttsService.speakText(step['text'], voiceId);
      
      // If TTS failed, wait for the estimated time
      if (!success) {
        await Future.delayed(Duration(seconds: step['text'].length ~/ 10));
      } else {
        await _ttsService.waitForCompletion();
      }
      
      // Pause between steps
      if (_isActive && mounted) {
        await Future.delayed(Duration(seconds: step['pauseAfter']));
      }
      
      // Check if session should end
      if (DateTime.now().isAfter(_endTime) || !_isActive) {
        break;
      }
    }
    
    // Continue with gentle breathing reminders until time is up
    while (_isActive && !_isCompleted && DateTime.now().isBefore(_endTime)) {
      await _playBreathingReminder();
    }
  }
  
  Future<void> _playBreathingReminder() async {
    if (!_isActive) return;
    
    final reminders = [
      "Continue breathing naturally and peacefully. Feel the healing warmth radiating from your relaxed body.",
      "Let each breath bring deeper calm and tranquility. Your body is releasing beautiful healing energy.",
      "Simply rest in this peaceful state. Your breath flows like gentle waves on a calm ocean.",
      "Feel the warm healing light flowing through every cell of your being with each soft breath.",
    ];
    
    final reminder = reminders[DateTime.now().second % reminders.length];
    final voiceId = context.read<VoiceProvider>().selectedVoiceId;
    await _ttsService.speakText(reminder, voiceId);
    await _ttsService.waitForCompletion();
    await Future.delayed(const Duration(seconds: 45));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and timer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                      onPressed: _stopExercise,
                    ),
                    Expanded(
                      child: Center(
                        child: _buildTimer(),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: AnimatedBuilder(
                  animation: _progressAnimationController,
                  builder: (context, child) {
                    return Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: LinearProgressIndicator(
                        value: _progressAnimationController.value,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Breathing animation
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _breathingAnimationController,
                    builder: (context, child) {
                      final animationValue = _breathingAnimationController.value;
                      return Container(
                        width: 200 + (animationValue * 80),
                        height: 200 + (animationValue * 80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.4 + (animationValue * 0.2)),
                              Colors.white.withOpacity(0.2 + (animationValue * 0.1)),
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20 + (animationValue * 20),
                              spreadRadius: 5 + (animationValue * 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.air,
                            size: 80 + (animationValue * 20),
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Current guidance text
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: _buildCurrentGuidanceText(),
                  ),
                ),
              ),
              
              // Control buttons
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildControlButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimer() {
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        if (_isCompleted) {
          return const Text(
            'Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          );
        }
        
        final now = DateTime.now();
        final remaining = _endTime.difference(now);
        
        if (remaining.isNegative && !_isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _completeExercise();
          });
          return const Text(
            'Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          );
        }
        
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        
        return Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w200,
            fontFamily: 'monospace',
            letterSpacing: 3,
          ),
        );
      },
    );
  }
  
  Widget _buildCurrentGuidanceText() {
    if (_isCompleted) {
      return Text(
        'Session complete. Take a moment to feel the warmth and peace in your body.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 18,
          fontWeight: FontWeight.w300,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(duration: 1000.ms);
    }
    
    if (_currentStepIndex < _guidanceSteps.length) {
      return Text(
        _guidanceSteps[_currentStepIndex]['text'],
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 18,
          fontWeight: FontWeight.w300,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(duration: 1000.ms);
    }
    
    return Text(
      'Continue breathing naturally and peacefully...',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 18,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  Widget _buildControlButtons() {
    if (_isCompleted) {
      return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            foregroundColor: const Color(AppConfig.primaryBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Finish Session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pause/Resume button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: "pauseButton",
            onPressed: _isPaused ? _resumeExercise : _pauseExercise,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: const Color(AppConfig.primaryBlue),
              size: 32,
            ),
          ),
        ),
        
        // Stop button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: "stopButton",
            onPressed: _stopExercise,
            backgroundColor: Colors.red.withOpacity(0.8),
            child: const Icon(
              Icons.stop,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
  
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'End Session?',
          style: TextStyle(
            color: Color(AppConfig.primaryBlue),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to end your Buteyko breathing session?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit exercise
            },
            child: const Text(
              'End Session',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}