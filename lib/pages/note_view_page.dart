import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';  // Import to handle document URL launching

class NoteViewPage extends StatefulWidget {
  final String title;
  final String? note;
  final String? imageUrl; // Add this line to accept image URL
  final String? documentUrl;

  const NoteViewPage(
      {super.key,
        required this.title,
        this.note,
        this.imageUrl,
        this.documentUrl});

  @override
  _NoteViewPageState createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
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
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                widget.note ?? 'No content available',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Display preview based on attachment
              if (widget.imageUrl == null)
                const SizedBox(height: 20)
              else if (widget.imageUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    // Show the image in full screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImagePage(imageUrl: widget.imageUrl!),
                      ),
                    );
                  },
                  child: Image.network(
                    widget.imageUrl!,
                    height: 200, // Adjust height as needed
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              if (widget.documentUrl?.isEmpty ?? true)
                const SizedBox(height: 20)
              else if (widget.documentUrl!.isNotEmpty)
                const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  // Open the document URL in the browser
                  if (await canLaunchUrl(Uri.parse(widget.documentUrl!))) {
                    await launchUrl(Uri.parse(widget.documentUrl!),
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Could not open document')),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file,
                        color: Colors.white, size: 40),
                    const SizedBox(width: 8),
                    const Text(
                      'View Attached Document',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FullScreenImagePage to view the image in full screen
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image'),
      ),
      body: Center(
        child: Image.network(imageUrl), // Display the full image
      ),
    );
  }
}
