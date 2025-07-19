import 'package:flutter/material.dart';
import 'package:pet_app/features/pet/widgets/voice_command_widget.dart';

class DraggableAIFab extends StatefulWidget {
  final VoidCallback? onTap;
  const DraggableAIFab({super.key, this.onTap});

  @override
  State<DraggableAIFab> createState() => _DraggableAIFabState();
}

class _DraggableAIFabState extends State<DraggableAIFab> {
  Offset position = const Offset(20, 500); // Varsayılan sağ alt

  void _openAssistantPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
        child: const VoiceCommandWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _buildFab(theme),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            double x = details.offset.dx.clamp(0, size.width - 70);
            double y = details.offset.dy.clamp(0, size.height - 70);
            position = Offset(x, y);
          });
        },
        child: GestureDetector(
          onTap: widget.onTap ?? _openAssistantPanel,
          child: _buildFab(theme),
        ),
      ),
    );
  }

  Widget _buildFab(ThemeData theme) {
    return Material(
      elevation: 10,
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mic, color: Colors.white, size: 32),
            SizedBox(height: 2),
            Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 