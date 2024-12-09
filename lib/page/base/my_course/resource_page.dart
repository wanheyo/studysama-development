import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/user_course.dart';
import 'package:studysama/page/base/my_course/manage_resource_page.dart';
import 'package:studysama/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/comment.dart';
import '../../../models/resource.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';

class ResourcePage extends StatefulWidget {
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;
  String token = "";

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
  // List<String> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool isLoadingComments = true;

  Color cardColor = Colors.grey[300]!;
  String resourceType = "Other";

  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;
  String token = "";

  List<UserCourse> userCourse = [];
  List<Comment> comments = [];

  List<Comment> filteredComments = [];
  String selectedFilter = 'All';
  String selectedSort = 'Newest';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await loadUser();
    //fetchUserCourse();
    _fetchComments();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        token = tokenString;
      }

      setState(() {
        // context.loaderOverlay.show();
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        // context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      context.loaderOverlay.show();
      isLoadingComments = true;
    });

    try {
      final data = await apiService.index_comment_resource(token, widget.resource.id);

      // Map `ResourceFile` data for quick lookup by `fileId`.
      final userCourseMap = {
        for (var file in (data['user_courses'] as List))
          file['id']: UserCourse.fromJson(file)
      };

      final userMap = {
        for (var file in (data['users'] as List))
          file['id']: User.fromJson(file)
      };

      // Combine `Resource` with corresponding `ResourceFile`.
      setState(() {
        comments = (data['comments'] as List)
            .map((json) {
          final comment = Comment.fromJson(json);
          comment.userCourse = userCourseMap[comment.userCourseId];
          comment.userCourse?.user = userMap[comment.userCourse?.userId];
          return comment;
        }).toList();

        _applyFiltersAndSort();
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
        isLoadingComments = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    // Start with the original comments list
    List<Comment> tempComments = List.from(comments);

    // Apply filtering
    if (selectedFilter == 'Tutor') {
      tempComments = tempComments.where((comment) => comment.userCourse!.roleId == 1).toList();
    }

    // Apply sorting
    if (selectedSort == 'Newest') {
      tempComments.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    } else if (selectedSort == 'Oldest') {
      tempComments.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    }

    // Update the filteredComments list
    setState(() {
      filteredComments = tempComments;
    });
  }


  Future<void> _addComment(String comment) async {
    if (comment.isNotEmpty) {
      setState(() {
        // comments.add(comment);
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget thumbnail = _buildThumbnail();


    // Determine card color and resource type based on category
    switch (widget.resource.category) {
      case 1:
        cardColor = Colors.blue[300]!;
        resourceType = "Note (Lecture)";
        break;
      case 2:
        cardColor = Colors.red[300]!;
        resourceType = "Assignment (Lab)";
        break;
      default:
        cardColor = Colors.grey[300]!;
        resourceType = "Other";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(resourceType),
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
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Fixed Resource Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                          color: Colors.white,
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
                  buildResourceInfoSection(),
                  // Second Card (Comments Section)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Comments Header and Metadata
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Comments:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
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
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
        
                            const SizedBox(height: 16),
        
                            // Filter and Sort Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Segmented Button for Filter with horizontal scrolling
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildSegmentedButton('All'),
                                        const SizedBox(width: 8),
                                        _buildSegmentedButton('Tutor'),
                                      ],
                                    ),
                                  ),
                                ),
                                // Sort Button fixed on the right
                                DropdownButton<String>(
                                  value: selectedSort,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedSort = newValue!;
                                    });
                                    _applyFiltersAndSort();
                                  },
                                  items: <String>['Newest', 'Oldest']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
        
                            const SizedBox(height: 16),
                            // Comments List (Scrollable)
                            if(filteredComments.isNotEmpty)
                              SizedBox(
                                height: 200,
                                child: isLoadingComments
                                    ? const Center(child: CircularProgressIndicator()) :
                                SingleChildScrollView(
                                  child: Column(
                                    children: filteredComments.map((comment) => _buildCommentCard(comment)).toList(),
                                  ),
                                ),
                              ),
                            if(filteredComments.isEmpty)
                              const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    "No comment found.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
        
                            // Comment Input
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: InputDecoration(
                                      hintText: "Add a comment...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _addComment(_commentController.text.trim());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text("Post"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Resource Info Section
  Widget buildResourceInfoSection() {
    switch (widget.resource.category) {
      case 1:
        cardColor = Colors.blue[300]!;
        resourceType = "Note (Lecture)";
        break;
      case 2:
        cardColor = Colors.red[300]!;
        resourceType = "Assignment (Lab)";
        break;
      default:
        cardColor = Colors.grey[300]!;
        resourceType = "Other";
    }

    return Column(
      children: [
        // First Card: Title and Description
        Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.resource.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      child: Text(
                        resourceType,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.resource.description ?? "No description available.",
                    style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
            color: Colors.grey[300],
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
                    color: Colors.grey[300], // Match the detail side color
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
        color: Colors.grey[300],
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

  // Build a comment card
  Widget _buildCommentCard(Comment comment) {
    return LoaderOverlay(
      child: Card(
        color: Colors.grey[100],
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username and Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userCourse!.user!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (comment.userCourse!.roleId == 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: Card(
                            color: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Text(
                                'Tutor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy hh:mm a').format(comment.createdAt!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Comment Content
              Text(
                comment.commentText,
                // maxLines: 4,
                // overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Build segmented button
  Widget _buildSegmentedButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedFilter = label;
        });
        _applyFiltersAndSort();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedFilter == label ? AppColors.primary : AppColors.accent,
      ),
      child: Text(label),
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
