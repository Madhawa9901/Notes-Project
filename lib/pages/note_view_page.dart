import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';  // Import to handle document URL launching

class NoteViewPage extends StatelessWidget {
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
                title,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                note ?? 'No content available',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Display attachment if imageUrl is provided
              if (imageUrl != null && imageUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    // Show the image in full screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImagePage(imageUrl: imageUrl!),
                      ),
                    );
                  },
                  child: Image.network(
                    imageUrl!,
                    height: 200, // Adjust height as needed
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              // Spacer
              const SizedBox(height: 16),

              // Display document icon if a document is attached
              if (documentUrl != null && documentUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    // Open the document URL in the browser
                    if (await canLaunchUrl(Uri.parse(documentUrl!))) {
                      await launchUrl(Uri.parse(documentUrl!),
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
