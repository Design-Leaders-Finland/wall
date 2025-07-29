// Cooldown timer widget that displays remaining time until next message can be sent
// Shows a countdown timer with visual progress indicator
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/message_service.dart';

class CooldownTimer extends StatefulWidget {
  final DateTime lastMessageTime;
  final VoidCallback? onCooldownExpired;

  const CooldownTimer({
    super.key,
    required this.lastMessageTime,
    this.onCooldownExpired,
  });

  @override
  State<CooldownTimer> createState() => _CooldownTimerState();
}

class _CooldownTimerState extends State<CooldownTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _calculateRemainingTime();
    _startTimer();
  }

  void _calculateRemainingTime() {
    final elapsed = DateTime.now().difference(widget.lastMessageTime);
    final totalCooldownSeconds = MessageService.messageCooldownMinutes * 60;
    _remainingSeconds = totalCooldownSeconds - elapsed.inSeconds;

    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      widget.onCooldownExpired?.call();
    } else {
      // Update progress animation
      final progress = 1.0 - (_remainingSeconds / totalCooldownSeconds);
      _progressController.animateTo(progress);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemainingTime();
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          widget.onCooldownExpired?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colorScheme.error.withAlpha(150), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer icon
          Icon(Icons.schedule, size: 16.0, color: colorScheme.error),
          const SizedBox(width: 8.0),
          // Countdown text
          Text(
            'Next message in ${_formatTime(_remainingSeconds)}',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(width: 12.0),
          // Progress indicator
          SizedBox(
            width: 60.0,
            height: 4.0,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: colorScheme.error.withAlpha(100),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.error),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
