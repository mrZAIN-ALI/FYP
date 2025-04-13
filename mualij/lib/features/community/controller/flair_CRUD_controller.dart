import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/failure.dart';
import 'package:mualij/features/community/repository/communitory_repository.dart';
import 'package:mualij/models/community_model.dart';
import 'package:fpdart/fpdart.dart';

// Create a provider family for the FlairController.
// It holds an AsyncValue<List<String>> representing the current flairs.
final flairControllerProvider = StateNotifierProvider.family<FlairController, AsyncValue<List<String>>, String>((ref, communityName) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return FlairController(communityRepository: communityRepository, communityName: communityName);
});

class FlairController extends StateNotifier<AsyncValue<List<String>>> {
  final CommunityRepository _communityRepository;
  final String communityName;
  StreamSubscription<Community>? _subscription;

  FlairController({required CommunityRepository communityRepository, required this.communityName})
      : _communityRepository = communityRepository,
        super(const AsyncValue.loading()) {
    // Subscribe to community changes to get updates to flairs.
    _subscription =
        _communityRepository.getCommunityByName(communityName).listen((community) {
      state = AsyncValue.data(community.flairs);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addFlair(String flair) async {
    if (flair.isEmpty) return;
    // Check for duplicate flair.
    final currentFlairs = state.value ?? [];
    if (currentFlairs.contains(flair)) return;

    state = const AsyncValue.loading();
    final res = await _communityRepository.addFlair(communityName, flair);
    res.fold(
      (l) {
        state = AsyncValue.error(l.message, StackTrace.current);
      },
      (r) {
        // The subscription will update state automatically.
      }
    );
  }

  Future<void> removeFlair(String flair) async {
    // Prevent deletion of default flairs.
    if (flair == "General" || flair == "Urgent") return;
    state = const AsyncValue.loading();
    final res = await _communityRepository.removeFlair(communityName, flair);
    res.fold(
      (l) {
        state = AsyncValue.error(l.message, StackTrace.current);
      },
      (r) {
        // State will update from the subscription.
      }
    );
  }


  Future<void> updateFlair(String oldFlair, String newFlair) async {
    // Prevent updating default flairs if desired.
    if (oldFlair == "General" || oldFlair == "Urgent") return;
    if (newFlair.isEmpty) return;
    state = const AsyncValue.loading();
    final res = await _communityRepository.updateFlair(communityName, oldFlair, newFlair);
    res.fold(
      (l) => state = AsyncValue.error(l.message, StackTrace.current),
      (r) {
        // The stream subscription will update state.
      }
    );
  }
}
