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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;

  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
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
        setState(() async{
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
    ref.read(userProfileControllerProvider.notifier).editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          name: nameController.text.trim(),
          bannerWebFile: bannerWebFile,
          profileWebFile: profileWebFile,
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
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
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
                                    color: currentTheme
                                        .textTheme.bodyLarge!.color!,
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
                                                      user.banner ==
                                                          Constants
                                                              .bannerDefault
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons
                                                            .camera_alt_outlined,
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
                                            backgroundImage:
                                                MemoryImage(profileWebFile!),
                                            radius: 32,
                                          )
                                        : profileFile != null
                                            ? CircleAvatar(
                                                backgroundImage:
                                                    FileImage(profileFile!),
                                                radius: 32,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    user.profilePic),
                                                radius: 32,
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                        ],
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
