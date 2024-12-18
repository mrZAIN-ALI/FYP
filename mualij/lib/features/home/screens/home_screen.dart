import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/home/delegates/search_community_delegate.dart';
import 'package:mualij/features/home/drawers/community_list_drawer.dart';
import 'package:mualij/features/home/drawers/profile_drawer.dart';
import 'package:mualij/features/home/search/search_delegate.dart';
// import 'package:mualij/features/home/search/search_delegate.dart';
import 'package:mualij/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Image.asset(
          Constants.logoPath, 
          width: 40,
          height: 40,
        ),
        centerTitle: true,
        title: const Text('Mualij'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Trigger the search delegate
              showSearch(
                context: context,
                delegate: GlobalSearchDelegate( ref: ref, context: context),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () =>  displayEndDrawer(context),
          ),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: null,
      endDrawer: ProfileDrawer(),
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : BottomNavigationBar(
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              currentIndex: _page,
              onTap: (index) => _onBottomNavTap(index, context),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Add Post',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome),
                  label: 'AI Models',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
              ],
            ),
    );
  }

  void _onBottomNavTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        Routemaster.of(context).push('/');
        break;
      case 1:
        Routemaster.of(context).push('/add-post');
        break;
      case 2:
        Routemaster.of(context).push('/ai-options');
        break;
      case 3:
        Routemaster.of(context).push('/');
        break;
    }
  }
}
