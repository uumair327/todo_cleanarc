import 'package:flutter/material.dart';
import '../services/realtime_service.dart';

/// Widget that displays the real-time connection status
/// 
/// Shows a small indicator when real-time updates are active
class RealtimeStatusIndicator extends StatelessWidget {
  final RealtimeService realtimeService;
  final bool showWhenDisconnected;

  const RealtimeStatusIndicator({
    super.key,
    required this.realtimeService,
    this.showWhenDisconnected = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscribed = realtimeService.isSubscribed;

    if (!isSubscribed && !showWhenDisconnected) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSubscribed
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSubscribed ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSubscribed ? Icons.wifi : Icons.wifi_off,
            size: 14,
            color: isSubscribed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isSubscribed ? 'Live' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSubscribed ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated real-time status indicator with pulse effect
class AnimatedRealtimeIndicator extends StatefulWidget {
  final RealtimeService realtimeService;

  const AnimatedRealtimeIndicator({
    super.key,
    required this.realtimeService,
  });

  @override
  State<AnimatedRealtimeIndicator> createState() =>
      _AnimatedRealtimeIndicatorState();
}

class _AnimatedRealtimeIndicatorState extends State<AnimatedRealtimeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = widget.realtimeService.isSubscribed;

    if (!isSubscribed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
