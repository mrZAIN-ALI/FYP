import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/tags_or_flair_chips.dart';
import 'package:mualij/features/community/controller/flair_CRUD_controller.dart';


// Provider to hold the current search query for flairs.
final flairSearchQueryProvider = StateProvider<String>((ref) => '');

class TaggingFlairsScreen extends ConsumerWidget {
  final String communityName;
  const TaggingFlairsScreen({Key? key, required this.communityName})
      : super(key: key);

  // Helper method for showing error messages.
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flairState = ref.watch(flairControllerProvider(communityName));
    final searchQuery = ref.watch(flairSearchQueryProvider);
    final newFlairController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagging/Flairs Options'),
      ),
      body: flairState.when(
        data: (flairs) {
          // Filter the flairs based on the search query.
          final filteredFlairs = flairs.where((flair) {
            return flair.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          // Separate default flairs from custom ones.
          final defaultFlairs = filteredFlairs
              .where((f) => f == "General" || f == "Urgent")
              .toList();
          final customFlairs = filteredFlairs
              .where((f) => f != "General" && f != "Urgent")
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field using hintText to avoid floating label behavior.
                TextField(
                  onChanged: (value) {
                    ref.read(flairSearchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Flairs',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // New flair input field with an "Add" button.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newFlairController,
                        decoration: InputDecoration(
                          hintText: 'New Flair',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () {
                        final newFlair = newFlairController.text.trim();
                        if (newFlair.isEmpty) return;
                        if (newFlair.length > 15) {
                          _showError(context, "Flair cannot exceed 15 characters.");
                          return;
                        }
                        // Disallow whitespace or special characters.
                        final regExp = RegExp(r'^[A-Za-z0-9]+$');
                        if (!regExp.hasMatch(newFlair)) {
                          _showError(context, "Flair must contain letters and numbers only (no spaces).");
                          return;
                        }
                        final currentFlairs = ref
                            .read(flairControllerProvider(communityName))
                            .maybeWhen(data: (data) => data, orElse: () => <String>[]);
                        if (currentFlairs.any((element) => element.toLowerCase() == newFlair.toLowerCase())) {
                          _showError(context, "Flair must be unique.");
                          return;
                        }
                        ref.read(flairControllerProvider(communityName).notifier).addFlair(newFlair);
                        newFlairController.clear();
                        // Reset search query after adding.
                        ref.read(flairSearchQueryProvider.notifier).state = '';
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Display Default Flairs section.
                const Text(
                  'Default Flairs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: defaultFlairs.map((flair) {
                    return FlairChipWidget(flair: flair);
                  }).toList(),
                ),
                const Divider(height: 32),
                // Display Custom Flairs section with edit and delete options.
                const Text(
                  'Custom Flairs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customFlairs.length,
                  itemBuilder: (context, index) {
                    final flair = customFlairs[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlairChipWidget(flair: flair),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final newFlair = await showDialog<String>(
                                  context: context,
                                  builder: (_) {
                                    final editController = TextEditingController(text: flair);
                                    return AlertDialog(
                                      title: const Text('Edit Flair'),
                                      content: TextField(
                                        controller: editController,
                                        decoration: const InputDecoration(
                                          hintText: 'New Flair',
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, editController.text.trim());
                                          },
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (newFlair != null && newFlair.isNotEmpty) {
                                  if (newFlair.length > 15) {
                                    _showError(context, "Flair cannot exceed 15 characters.");
                                    return;
                                  }
                                  final regExp = RegExp(r'^[A-Za-z0-9]+$');
                                  if (!regExp.hasMatch(newFlair)) {
                                    _showError(context, "Flair must contain only letters and numbers (no spaces).");
                                    return;
                                  }
                                  final currentFlairs = ref
                                      .read(flairControllerProvider(communityName))
                                      .maybeWhen(data: (data) => data, orElse: () => <String>[]);
                                  if (currentFlairs.any((element) =>
                                      element.toLowerCase() == newFlair.toLowerCase() &&
                                      element.toLowerCase() != flair.toLowerCase())) {
                                    _showError(context, "Flair must be unique.");
                                    return;
                                  }
                                  await ref.read(flairControllerProvider(communityName).notifier).updateFlair(flair, newFlair);
                                  // Reset search query after update.
                                  ref.read(flairSearchQueryProvider.notifier).state = '';
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref.read(flairControllerProvider(communityName).notifier).removeFlair(flair);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
