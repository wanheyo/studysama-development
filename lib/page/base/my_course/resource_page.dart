import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studysama/page/base/my_course/manage_resource_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/resource.dart';
import '../../../services/api_service.dart';

class ResourcePage extends StatefulWidget {
  final Resource resource;
  bool isTutor;
  final VoidCallback onDelete;

  ResourcePage({
    Key? key,
    required this.resource,
    required this.onDelete,
    required this.isTutor
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
    String resourceType;

    // Determine card color and resource type based on category
    switch (widget.resource.category) {
      case 1:
        appBarColor = Colors.blue[200]!;
        resourceType = "Note (Lecture)";
        break;
      case 2:
        appBarColor = Colors.red[200]!;
        resourceType = "Assignment (Lab)";
        break;
      default:
        appBarColor = Colors.grey[200]!;
        resourceType = "Other";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.id.toString()),
        actions: [
          if (widget.isTutor)
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: PopupMenuButton<String>(
                icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Colors.black),
                onSelected: (String value) async {
                  switch (value) {
                    case 'Manage Resource':
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageResourcePage(
                            resource: widget.resource,
                          ),
                        ),
                      );
                      break;
                    case 'Hint':
                    // _showHint();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Manage Resource',
                      child: Text('Manage Resource'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Hint',
                      child: Text('Hint'),
                    ),
                  ];
                },
              ),
            ),
        ],
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Fixed Resource Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: appBarColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                        color: Colors.grey[100],
                        child: GestureDetector(
                          child: thumbnail,
                          onTap: () async {
                            if(widget.resource.resourceFile != null) {
                              final Uri uri = Uri.parse(domainURL + '/storage/${widget.resource.resourceFile!.name}',);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Could not download file")),
                                );
                              }
                            }

                            if(widget.resource.link != null) {
                              final Uri uri = Uri.parse(widget.resource.link!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Could not open link")),
                                );
                              }
                            }
                          },
                        )
                    )
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
                const SizedBox(height: 4),
                Text(
                  "| " + resourceType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Description:",
                  style: TextStyle(
                    fontSize: 16,
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
                if (widget.resource.description == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "No description provided",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 50),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text(
                    //   "Comments ...",
                    //   style: const TextStyle(
                    //     fontSize: 18,
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.bold,
                    //     fontFamily: 'Montserrat',
                    //   ),
                    // ),
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
                          size: 20,
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
      return SizedBox(
        height: 200,
        child: AnyLinkPreview.builder(
          link: widget.resource.link!,
          cache: const Duration(days: 7),
          errorWidget: Container(
            color: Colors.grey[200],
            height: 200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.link,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Preview not available",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          itemBuilder: (context, metadata, imageProvider, _) {
            return Row(
              children: [
                // Image section with gray background
                Container(
                  width: 100,
                  height: 100,
                  child: imageProvider != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover, // Ensure the image does not stretch
                    ),
                  )
                      : null, // If no image, keep the gray background
                ),
                const SizedBox(width: 8), // Space between image and text
                // Text details section
                Expanded(
                  child: Container(
                    color: Colors.grey[200], // Match the detail side color
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (metadata.title != null)
                          Text(
                            metadata.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (metadata.desc != null)
                          Text(
                            metadata.desc!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          metadata.url ?? widget.resource.link!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (widget.resource.resourceFile != null) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  getFileIcon(widget.resource.resourceFile!.type),
                  size: 40
              ),
              const SizedBox(height: 8),
              Text(
                "Preview not available",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
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
        Icon(icon, size: 20),
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
