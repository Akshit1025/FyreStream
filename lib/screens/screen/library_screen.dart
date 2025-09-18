import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fyrestream/blocs/library/cubit/library_items_cubit.dart';
import 'package:fyrestream/routes_and_consts/global_str_consts.dart';
import 'package:fyrestream/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:fyrestream/screens/widgets/smallPlaylistCard_widget.dart';
import 'package:fyrestream/services/db/MediaDB.dart';

import 'package:fyrestream/theme_data/default.dart';
import '../widgets/unicode_icons.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          customDiscoverBar(context), //AppBar
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height,
                  child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        child: state.playlists.isNotEmpty
                            ? ListOfPlaylists(state: state)
                            : Center(
                                child: SizedBox(
                                  width: 100,
                                  height: 50,
                                  child: Text(
                                    "Get started by adding items to library!!",
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(
                                          const TextStyle(
                                            color: Default_Theme.primaryColor2,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
      backgroundColor: Default_Theme.themeColor,
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Library",
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(fontSize: 34, color: Default_Theme.primaryColor1),
            ),
          ),
          const Spacer(),
          const UnicodeIcon(
            strCode: "\uf002",
            font: Default_Theme.fontAwesomeSolidFont,
            fontSize: 24.0,
            padding: EdgeInsets.only(left: 7, right: 7),
          ),
          InkWell(
            onTap: () {
              createPlaylistBottomSheet(context);
            },
            child: const UnicodeIcon(
              strCode: "\u002b",
              font: Default_Theme.fontAwesomeSolidFont,
              fontSize: 25.0,
              padding: EdgeInsets.only(left: 7, right: 7),
            ),
          ),
          InkWell(
            onTap: () {
              context.pushNamed(GlobalStrConsts.ImportMediaFromPlatforms);
            },
            child: const UnicodeIcon(
              strCode: "\uf56f",
              font: Default_Theme.fontAwesomeSolidFont,
              fontSize: 25.0,
              padding: EdgeInsets.only(left: 7, right: 5),
            ),
          ),
        ],
      ),
    );
  }
}

class ListOfPlaylists extends StatefulWidget {
  LibraryItemsState state;

  ListOfPlaylists({super.key, required this.state});

  @override
  State<ListOfPlaylists> createState() => _ListOfPlaylistsState();
}

class _ListOfPlaylistsState extends State<ListOfPlaylists> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.state.playlists.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Dismissible(
          key: ValueKey(widget.state.playlists[index].playlistName),
          background: Container(color: Colors.green),
          secondaryBackground: Container(
            color: Colors.red,
            child: const Row(
              children: [
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    FluentIcons.delete_dismiss_28_regular,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {
            context.read<LibraryItemsCubit>().removePlaylist(
              MediaPlaylistDB(
                playlistName:
                    widget.state.playlists[index].playlistName ?? "Null",
              ),
            );
            setState(() {
              widget.state.playlists.removeAt(index);
            });
          },
          child: InkWell(
            onTap: () => context.pushNamed(
              GlobalStrConsts.playlistView,
              pathParameters: {
                "playlistName":
                    widget.state.playlists[index].playlistName ?? "Liked",
              },
            ),
            child: SmallPlaylistCard(
              playListTitle:
                  widget.state.playlists[index].playlistName ?? "Unknown",
              coverArt: Image(
                image: widget.state.playlists[index].imageProvider!,
                fit: BoxFit.fitHeight,
              ),
              playListsubTitle:
                  widget.state.playlists[index].subTitle ?? "Unknown",
            ),
          ),
        ),
      ),
    );
  }
}
