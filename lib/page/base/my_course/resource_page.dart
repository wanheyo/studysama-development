import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/resource.dart';
import '../../../services/api_service.dart';

class ResourcePage extends StatefulWidget {
  final Resource resource;
  final VoidCallback onDelete;

  const ResourcePage({
    Key? key,
    required this.resource,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ResourcePageState createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  List<String> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool isLoadingComments = true;

  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() {
      isLoadingComments = true;
    });

    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        comments = [
          "Great resource!",
          "Can you upload a new version?",
          "Thanks for sharing!",
        ];
        isLoadingComments = false;
      });
    });
  }

  Future<void> _addComment(String comment) async {
    if (comment.isNotEmpty) {
      setState(() {
        comments.add(comment);
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget thumbnail = _buildThumbnail();
    Color appBarColor;

    if(widget.resource.category == 1)
      appBarColor = Colors.blue[100]!;
    else if(widget.resource.category == 2)
      appBarColor = Colors.red[100]!;
    else
      appBarColor = Colors.grey[100]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.name),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.trash),
            tooltip: 'Delete Resource',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: const Text("Are you sure you want to delete this resource?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onDelete();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed Resource Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: thumbnail,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.resource.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                if (widget.resource.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "${widget.resource.description}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 30),
                // Buttons and Metadata Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Buttons on the Left
                    Row(
                      children: [
                        if (widget.resource.resourceFile != null)
                          _buildActionButton(
                            icon: FontAwesomeIcons.download,
                            label: "Download",
                            onPressed: () async {
                              final Uri uri = Uri.parse(
                                domainURL + '/storage/${widget.resource.resourceFile!.name}',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Could not download file")),
                                );
                              }
                            },
                          ),
                        if (widget.resource.link != null)
                          _buildActionButton(
                            icon: FontAwesomeIcons.link,
                            label: "Open Link",
                            onPressed: () async {
                              final Uri uri = Uri.parse(widget.resource.link!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Could not open link")),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    const Spacer(), // Push metadata to the right
                    // Metadata on the Right
                    Row(
                      children: [
                        if (widget.resource.resourceFile != null) ...[
                          _buildDataRow(
                            icon: FontAwesomeIcons.download,
                            value: "${widget.resource.resourceFile!.totalDownload}",
                          ),
                          const SizedBox(width: 16),
                        ],
                        _buildDataRow(
                          icon: FontAwesomeIcons.comment,
                          value: "${comments.length}",
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          widget.resource.link != null
                              ? FontAwesomeIcons.link
                              : getFileIcon(widget.resource.resourceFile?.type ?? ""),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Scrollable Comment Section
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Expanded(
                    child: isLoadingComments
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return _buildCommentBubble(comments[index]);
                      },
                    ),
                  ),
                  // Comment Input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: "Add a comment...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _addComment(_commentController.text.trim());
                          },
                          child: const Text("Post"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Thumbnail for resource
  Widget _buildThumbnail() {
    if (widget.resource.link != null && isYouTubeLink(widget.resource.link!)) {
      String videoId = extractYouTubeVideoId(widget.resource.link!);
      String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
      );
    } else if (widget.resource.link != null) {
      // Use AnyLinkPreview for general link thumbnails
      return AnyLinkPreview(
        displayDirection: UIDirection.uiDirectionHorizontal,
        showMultimedia: true,
        bodyMaxLines: 3,
        bodyTextOverflow: TextOverflow.ellipsis,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        errorWidget: Container(
          color: Colors.grey[200],
          height: 200,
          child: const Center(
            child: Icon(
              FontAwesomeIcons.link,
              size: 80,
              color: Colors.black45,
            ),
          ),
        ),
        link: widget.resource.link!,
        cache: const Duration(days: 7),
        backgroundColor: Colors.white,
        borderRadius: 8.0,
      );
    } else if (widget.resource.resourceFile != null) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: Icon(
          getFileIcon(widget.resource.resourceFile!.type),
          size: 80,
          color: Colors.black45,
        ),
      );
    }
    return Container(); // Default thumbnail
  }

  // Build Action Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  // Build Data Row for total download, comments, or link icon
  Widget _buildDataRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Build a comment bubble
  Widget _buildCommentBubble(String comment) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          comment,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  // Utility functions
  bool isYouTubeLink(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  String extractYouTubeVideoId(String url) {
    Uri uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    }
    return '';
  }

  IconData getFileIcon(String fileType) {
    String normalizedType = fileType.toLowerCase().replaceAll('.', '');
    switch (normalizedType) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return FontAwesomeIcons.fileImage;
      default:
        return FontAwesomeIcons.file;
    }
  }
}
