import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/features/community/controller/community_controller.dart';
import 'package:mualij/responsive/responsive.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }


void createCommunity() {
  final name = communityNameController.text.trim();

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Community name is required.")),
    );
    return;
  }

  if (name.contains(' ')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Community name must not contain spaces.")),
    );
    return;
  }

  ref.read(communityControllerProvider.notifier).createCommunity(
        name,
        context,
      );
}


  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a community'),
      ),
      body: isLoading
          ? const Loader()
          : Responsive(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Community Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: communityNameController,
                      decoration: const InputDecoration(
                        hintText: 'c/Community Name',
                        filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLength: 21,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: createCommunity,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: const Text(
                        'Create community',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
