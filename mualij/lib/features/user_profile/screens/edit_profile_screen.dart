import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/core/utils.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/user_profile/controller/user_profile_controller.dart';
import 'package:mualij/responsive/responsive.dart';
import 'package:mualij/theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  
  late TextEditingController nameController;
  late TextEditingController backgroundController;
  late TextEditingController expertiseController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider)!;
    nameController = TextEditingController(text: user.name);
    backgroundController = TextEditingController(text: user.professionalBackground);
    expertiseController = TextEditingController(text: user.expertiseAreas.join(', '));
  }

  @override
  void dispose() {
    nameController.dispose();
    backgroundController.dispose();
    expertiseController.dispose();
    super.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() async {
          bannerWebFile = await res.readAsBytes();
        });
      } else {
        setState(() {
          bannerFile = File(res.path);
        });
      }
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() async {
          profileWebFile = await res.readAsBytes();
        });
      } else {
        setState(() {
          profileFile = File(res.path);
        });
      }
    }
  }

  void save() {
    final expertiseText = expertiseController.text.trim();
    final expertiseList = expertiseText.isNotEmpty
        ? expertiseText.split(',').map((e) => e.trim()).toList()
        : <String>[];

    ref.read(userProfileControllerProvider.notifier).editCommunity(
      profileFile: profileFile,
      bannerFile: bannerFile,
      profileWebFile: profileWebFile,
      bannerWebFile: bannerWebFile,
      context: context,
      name: nameController.text.trim(),
      professionalBackground: backgroundController.text.trim(),
      expertiseAreas: expertiseList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    
    return ref.watch(getUserDataProvider(widget.uid)).when(
      data: (user) => Scaffold(
        backgroundColor: currentTheme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: false,
          actions: [
            TextButton(
              onPressed: save,
              child: const Text('Save'),
            ),
          ],
        ),
        body: isLoading
            ? const Loader()
            : Responsive(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Banner and Profile Images Section
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color: currentTheme.textTheme.bodyLarge!.color!,
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
                                            : user.banner.isEmpty ||
                                                    user.banner == Constants.bannerDefault
                                                ? const Center(
                                                    child: Icon(
                                                      Icons.camera_alt_outlined,
                                                      size: 40,
                                                    ),
                                                  )
                                                : Image.network(user.banner),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: GestureDetector(
                                  onTap: selectProfileImage,
                                  child: profileWebFile != null
                                      ? CircleAvatar(
                                          backgroundImage: MemoryImage(profileWebFile!),
                                          radius: 32,
                                        )
                                      : profileFile != null
                                          ? CircleAvatar(
                                              backgroundImage: FileImage(profileFile!),
                                              radius: 32,
                                            )
                                          : CircleAvatar(
                                              backgroundImage: NetworkImage(user.profilePic),
                                              radius: 32,
                                            ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name Field Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.blue),
                            title: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: 'Name',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Professional Background Field Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.work_outline, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      "Professional Background",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: backgroundController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your professional background',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Areas of Expertise Field Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.star_border, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      "Areas of Expertise",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: expertiseController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter areas of expertise (comma separated)',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      loading: () => const Loader(),
      error: (error, stackTrace) => ErrorText(
        error: error.toString(),
      ),
    );
  }
}
