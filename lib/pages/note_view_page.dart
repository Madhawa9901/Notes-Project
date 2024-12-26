import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import to handle document URL launching

class NoteViewPage extends StatefulWidget {
  final String title;
  final String? note;
  final List<String>? imageUrls; // Updated to accept multiple image URLs
  final List<String>? documentUrls; // Updated to accept multiple document URLs

  const NoteViewPage({
    super.key,
    required this.title,
    this.note,
    this.imageUrls,
    this.documentUrls,
  });

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
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Note content
              Text(
                widget.note ?? 'No content available',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Display attached images
              if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
                const Text(
                  'Attached Images:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
                SizedBox(
                  height: 200, // Adjust height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imageUrls!.length,
                    itemBuilder: (context, index) {
                      final imageUrl = widget.imageUrls![index];
                      return GestureDetector(
                        onTap: () {
                          // Show the image in full screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullScreenImagePage(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Display attached documents
              if (widget.documentUrls != null && widget.documentUrls!.isNotEmpty)
                const Text(
                  'Attached Documents:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              if (widget.documentUrls != null && widget.documentUrls!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true, // Avoid overflow
                  itemCount: widget.documentUrls!.length,
                  itemBuilder: (context, index) {
                    final documentUrl = widget.documentUrls![index];
                    return GestureDetector(
                      onTap: () async {
                        // Open the document URL in the browser
                        if (await canLaunchUrl(Uri.parse(documentUrl))) {
                          await launchUrl(Uri.parse(documentUrl),
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open document'),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                Uri.parse(documentUrl).pathSegments.last,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis, // Handle long file names
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
