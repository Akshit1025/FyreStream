import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fyrestream/routes_and_consts/global_str_consts.dart';
import 'package:fyrestream/screens/screen/add_to_playlist_screen.dart';
import 'package:fyrestream/screens/screen/audioPlayer_screen.dart';
import 'package:fyrestream/screens/screen/explore_screen.dart';
import 'package:fyrestream/screens/screen/library_screen.dart';
import 'package:fyrestream/screens/screen/library_views/import_media_view.dart';
import 'package:fyrestream/screens/screen/library_views/playlist_screen.dart';
import 'package:fyrestream/screens/screen/offline_screen.dart';
import 'package:fyrestream/screens/screen/search_screen.dart';
import 'package:fyrestream/screens/screen/test_screen.dart';
import 'package:fyrestream/screens/widgets/global_navbar.dart';

class GlobalRoutes {
  static final globalRouterKey = GlobalKey<NavigatorState>();

  final globalRouter = GoRouter(
    initialLocation: '/${GlobalStrConsts.exploreScreen}',
    navigatorKey: globalRouterKey,
    routes: [
      GoRoute(
        name: GlobalStrConsts.playerScreen,
        path: "/MusicPlayer",
        parentNavigatorKey: globalRouterKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const AudioPlayerView(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  final tween = Tween(begin: begin, end: end);
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    reverseCurve: Curves.easeIn,
                    curve: Curves.easeInOut,
                  );
                  final offsetAnimation = curvedAnimation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        name: GlobalStrConsts.playlistView,
        path: '/PlaylistView/:playlistName',
        builder: (context, state) => PlaylistView(
          playListName: state.pathParameters['playlistName'] ?? "none",
        ),
      ),
      GoRoute(
        path: '/AddToPlaylist',
        name: GlobalStrConsts.addToPlaylistScreen,
        builder: (context, state) => AddToPlaylistScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffholdWithNavbar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.testScreen,
                path: '/Test',
                builder: (context, state) => TestView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.exploreScreen,
                path: '/Explore',
                builder: (context, state) => ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.libraryScreen,
                path: '/Library',
                builder: (context, state) => LibraryScreen(),
                routes: [
                  GoRoute(
                    path: "ImportMediaFromPlatforms",
                    name: GlobalStrConsts.ImportMediaFromPlatforms,
                    builder: (context, state) =>
                        const ImportMediaFromPlatformsView(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.searchScreen,
                path: '/Search',
                builder: (context, state) => SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.offlineScreen,
                path: '/Offline',
                builder: (context, state) => OfflineScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
