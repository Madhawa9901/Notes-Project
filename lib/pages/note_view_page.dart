import 'package:flutter/material.dart';

class NoteViewPage extends StatelessWidget {
  final String title;
  final String? note;

  const NoteViewPage({super.key, required this.title, this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.avif"),
                fit: BoxFit.fill
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16,),
              Text(note ?? 'No content available', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}