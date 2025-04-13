import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/common/tags_or_flair_chips.dart';
import 'package:mualij/core/utils.dart';
import 'package:mualij/features/community/controller/community_controller.dart';
import 'package:mualij/features/community/controller/flair_CRUD_controller.dart';
import 'package:mualij/features/post/controller/post_controller.dart';
import 'package:mualij/models/community_model.dart';
import 'package:mualij/responsive/responsive.dart';
import 'package:mualij/theme/pallete.dart';

// Import your custom chip widget (for both flairs and communities).
// import 'package:mualij/features/community/view/flair_chip_widget.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  ConsumerState<AddPostTypeScreen> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  File? bannerFile;
  Uint8List? bannerWebFile;
  List<Community> communities = [];
  Community? selectedCommunity;
  // Use a list so that more than one flair can be selected.
  List<String> selectedFlairs = [];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  /// When no community exists, prompt the user with a dialog.
  void _showNoCommunityDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No Community Found'),
        content: const Text(
            'You have not joined or created any community yet. Please join or create a community before creating a post.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, navigate to community join/create screen.
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() async {
          bannerWebFile = await res.readAsBytes();
        });
      }
      setState(() {
        bannerFile = File(res.path);
      });
    }
  }

  void sharePost() {
    if (communities.isEmpty) {
      _showNoCommunityDialog();
      return;
    }
    if (selectedCommunity == null) {
      showSnackBar(context, 'Please select a community.');
      return;
    }
    if (selectedFlairs.isEmpty) {
      showSnackBar(context, 'Please select at least one flair.');
      return;
    }

    // Now proceed with sharing based on post type, passing the list of selected flairs.
    if (widget.type == 'image' &&
        (bannerFile != null || bannerWebFile != null) &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            file: bannerFile,
            webFile: bannerWebFile,
            flairs: selectedFlairs,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            description: descriptionController.text.trim(),
            flairs: selectedFlairs,
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            link: linkController.text.trim(),
            flairs: selectedFlairs,
          );
    } else {
      showSnackBar(context, 'Please fill in all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Responsive(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Only show selected flairs if any are selected.
                          if (selectedFlairs.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedFlairs.map((flair) {
                                return FlairChipWidget(flair: flair);
                              }).toList(),
                            ),
                          if (selectedFlairs.isNotEmpty)
                            const SizedBox(height: 8),
                          // Title field.
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: 'Enter Title here',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(18),
                            ),
                            maxLength: 30,
                          ),
                          const SizedBox(height: 10),
                          if (isTypeImage)
                            GestureDetector(
                              onTap: selectBannerImage,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color:
                                    currentTheme.textTheme.bodyLarge?.color ??
                                        Colors.grey,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: bannerWebFile != null
                                      ? Image.memory(bannerWebFile!)
                                      : bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : const Center(
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 40,
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          if (isTypeText)
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                filled: true,
                                hintText: 'Enter Description here',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(18),
                              ),
                              maxLines: 5,
                            ),
                          if (isTypeLink)
                            TextField(
                              controller: linkController,
                              decoration: const InputDecoration(
                                filled: true,
                                hintText: 'Enter link here',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(18),
                              ),
                            ),
                          const SizedBox(height: 20),
                          // Community Selection Section using horizontal chips.
                          ref.watch(userCommunitiesProvider).when(
                                data: (data) {
                                  communities = data;
                                  if (data.isEmpty) {
                                    Future.delayed(
                                        Duration.zero, _showNoCommunityDialog);
                                    return const SizedBox();
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select Community',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: data.map((community) {
                                            bool isSelected =
                                                selectedCommunity?.id ==
                                                    community.id;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedCommunity =
                                                        community;
                                                    // Reset flairs when community changes.
                                                    selectedFlairs = [];
                                                  });
                                                },
                                                child: Container(
                                                  decoration: isSelected
                                                      ? BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.blue,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        )
                                                      : null,
                                                  child: FlairChipWidget(
                                                    flair: community.name,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                error: (error, stackTrace) => ErrorText(
                                  error: error.toString(),
                                ),
                                loading: () => const Loader(),
                              ),
                          const SizedBox(height: 20),
                          // Flair Selection Section.
                          if (selectedCommunity != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Flair(s)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ref
                                    .watch(flairControllerProvider(
                                        selectedCommunity!.name))
                                    .when(
                                      data: (flairs) {
                                        return Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: flairs.map((flair) {
                                            bool isSelected =
                                                selectedFlairs.contains(flair);
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedFlairs
                                                        .remove(flair);
                                                  } else {
                                                    selectedFlairs.add(flair);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: isSelected
                                                    ? BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.blue,
                                                            width: 2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      )
                                                    : null,
                                                child: FlairChipWidget(
                                                    flair: flair),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                      loading: () => const Center(
                                          child: CircularProgressIndicator()),
                                      error: (error, stack) =>
                                          Text('Error: $error'),
                                    ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
