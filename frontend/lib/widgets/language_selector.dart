import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final Color? iconColor;

  const LanguageSelector({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.language, color: iconColor ?? Colors.white),
      tooltip: 'Language / భాష / भाषा',
      onSelected: (String code) {
        languageService.setLanguage(code);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'te',
          child: Row(
            children: [
              Text('తెలుగు (Telugu)', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'hi',
          child: Row(
            children: [
              Text('हिन्दी (Hindi)', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
