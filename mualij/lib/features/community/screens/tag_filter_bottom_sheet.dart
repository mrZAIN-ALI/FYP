import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/tags_or_flair_chips.dart';
import 'package:mualij/features/community/controller/flair_CRUD_controller.dart';

class TagFilterBottomSheet extends ConsumerStatefulWidget {
  final String communityName;
  const TagFilterBottomSheet({Key? key, required this.communityName}) : super(key: key);

  @override
  ConsumerState<TagFilterBottomSheet> createState() => _TagFilterBottomSheetState();
}

class _TagFilterBottomSheetState extends ConsumerState<TagFilterBottomSheet> {
  List<String> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter by Tags'),
        actions: [
          if (selectedTags.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedTags.clear();
                });
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ref.watch(flairControllerProvider(widget.communityName)).when(
                  data: (flairs) => flairs.isEmpty
                      ? const Center(child: Text('No flairs found.'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: flairs.map((flair) {
                              final isSelected = selectedTags.contains(flair);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelected
                                        ? selectedTags.remove(flair)
                                        : selectedTags.add(flair);
                                  });
                                },
                                child: Container(
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          border: Border.all(color: Colors.blue, width: 2),
                                          borderRadius: BorderRadius.circular(16),
                                        )
                                      : null,
                                  child: FlairChipWidget(flair: flair),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedTags),
              child: const Text('Apply Filter'),
            ),
          ),
        ],
      ),
    );
  }
}
