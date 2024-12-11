import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/features/home/search/repo.dart';
import 'package:routemaster/routemaster.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class GlobalSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  final BuildContext context;
  late final TextEditingController _controller;
  late final ValueNotifier<String> _queryNotifier;
  late final StreamController<String> _debouncedQueryController;

  GlobalSearchDelegate({required this.ref, required this.context})
      : super(searchFieldLabel: 'Search users, communities, posts') {
    _controller = TextEditingController();
    _queryNotifier = ValueNotifier<String>(query);
    _debouncedQueryController = StreamController<String>();

    // Listen to the debounced query stream
    _debouncedQueryController.stream
        .debounceTime(const Duration(milliseconds: 300))
        .distinct()
        .listen((newQuery) {
      query = newQuery;
      showSuggestions(
          context); // Trigger suggestions update when debounced query is changed
    });
  }

  @override
  String get searchFieldLabel => 'Title, Communities, Username';

  @override
  TextStyle get searchFieldStyle => TextStyle(color: Colors.black);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _debouncedQueryController.add('');
          showSuggestions(context); // Show suggestions when query is cleared
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(); // Show the results dynamically as user types
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(); // Use the same method for suggestions
  }

  Widget buildSearchResults() {
    final searchRepo = ref.read(searchRepositoryProvider);

    final usersStream = searchRepo.searchUsers(query);
    final communitiesStream = searchRepo.searchCommunities(query);
    final postsStream = searchRepo.searchPosts(query);

    return StreamBuilder(
      stream: CombineLatestStream.list(
          [usersStream, communitiesStream, postsStream]),
      builder:
          (context, AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null ||
            snapshot.data!.every((list) => list.isEmpty)) {
          return const Center(child: Text('No results found'));
        }

        final users = snapshot.data![0];
        final communities = snapshot.data![1];
        final posts = snapshot.data![2];

        return ListView(
          children: [
            if (users.isNotEmpty) ...[
              _buildSectionTitle('Users'),
              ...users.map((user) => ListTile(
                    title: _buildHighlightedText(user['username'], query),
                    subtitle: Text(user['name']),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profilePic']),
                    ),
                    onTap: () {
                      // Navigate to User Profile
                      Routemaster.of(context).push('/u/${user['uid']}');
                    },
                  )),
            ],
            if (communities.isNotEmpty) ...[
              _buildSectionTitle('Communities'),
              ...communities.map((community) => ListTile(
                    title: _buildHighlightedText(community['name'], query),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(community['avatar']),
                    ),
                    onTap: () {
                      // Navigate to Community Page
                      Routemaster.of(context).push('/r/${community['name']}');
                    },
                  )),
            ],
            if (posts.isNotEmpty) ...[
              _buildSectionTitle('Posts'),
              ...posts.map((post) => ListTile(
                    title: _buildHighlightedText(post['title'], query),
                    subtitle: Text('By ${post['username']}'),
                    onTap: () {
                      // Navigate to Post Detail
                      // Routemaster.of(context).push('/p/${post['id']}');
                      // call her comment sceen
                      // Routemaster.of(context).push('/post/${post['id']}');
                      print("post['id'] ${post['id']}");
                      Routemaster.of(context).push('/post/${post['id']}/comments');

                    },
                  )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No results found for "$query"',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    final matchIndex = text.toLowerCase().indexOf(query.toLowerCase());
    if (matchIndex == -1) {
      return Text(text); // No match
    }

    final beforeMatch = text.substring(0, matchIndex);
    final matchText = text.substring(matchIndex, matchIndex + query.length);
    final afterMatch = text.substring(matchIndex + query.length);

    return RichText(
      text: TextSpan(
        text: beforeMatch,
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: matchText,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: afterMatch,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void close(BuildContext context, result) {
    super.close(context, result);
    _debouncedQueryController
        .close(); // Close the debounced query stream when search is closed
  }
}
