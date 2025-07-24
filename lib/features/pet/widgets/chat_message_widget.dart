import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pati_takip/features/pet/models/ai_chat_message.dart';
import 'package:pati_takip/services/media_service.dart';

class ChatMessageWidget extends StatelessWidget {
  final AIChatMessage message;
  final bool isUser;
  final VoidCallback? onVoicePlay;
  final VoidCallback? onImageTap;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.onVoicePlay,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 48,
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildMessageContent(context),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.voice:
        return _buildVoiceMessage();
      case MessageType.image:
        return _buildImageMessage();
    }
  }

  Widget _buildTextMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            message.text,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow, size: 24),
          onPressed: onVoicePlay ?? () {
            if (message.mediaUrl != null) {
              MediaService().playVoiceFile(message.mediaUrl!);
            }
          },
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text.isNotEmpty ? message.text : 'Ses mesajı',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (message.voiceDuration != null)
              Text(
                MediaService().formatDuration(message.voiceDuration!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.mediaUrl != null)
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.mediaUrl!),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
          ),
        if (message.text.isNotEmpty || message.imageCaption != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message.text.isNotEmpty ? message.text : message.imageCaption ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }
} 