import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fyrestream/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:fyrestream/screens/widgets/smallPlaylistCard_widget.dart';
import 'package:fyrestream/services/db/MediaDB.dart';
import 'package:fyrestream/services/db/cubit/mediadb_cubit.dart';
import 'package:fyrestream/theme_data/default.dart';
import 'package:fyrestream/routes_and_consts/global_consts.dart';
import 'package:fyrestream/utils/load_Image.dart';

class AddToPlaylistScreen extends StatefulWidget {
  AddToPlaylistScreen({super.key});

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  List<PlaylistItemProperties> playlistsItems = List.empty(growable: true);

  List<PlaylistItemProperties> filteredPlaylistsItems = List.empty(
    growable: true,
  );
  final TextEditingController _searchController = TextEditingController();

  Future<void> searchFilter(String query) async {
    if (query.length > 0) {
      setState(() {
        filteredPlaylistsItems = playlistsItems.where((element) {
          return element.playlistName?.toLowerCase().contains(
                query.toLowerCase(),
              ) ??
              false;
        }).toList();
      });
    } else {
      setState(() {
        filteredPlaylistsItems = playlistsItems;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AddToPlaylistCubit>().getAndEmitPlaylists();
  }

  MediaItemModel currentMediaModel = mediaItemModelNull;

  @override
  Widget build(BuildContext context) {
    // context.read<AddToPlaylistCubit>().getAndEmitPlaylists();
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Add to Playlist',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<MediaItemModel>(
            stream: context.watch<AddToPlaylistCubit>().mediaItemModelBS,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != mediaItemModelNull) {
                currentMediaModel = snapshot.data ?? mediaItemModelNull;
                return Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: loadImageCached(
                                snapshot.data?.artUri.toString() ?? "",
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    snapshot.data?.title ?? "Unknown",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(
                                          const TextStyle(
                                            color: Default_Theme.primaryColor2,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                  ),
                                ),
                                Text(
                                  snapshot.data?.artist ?? "Unknown",
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: Default_Theme.secondoryTextStyle.merge(
                                    TextStyle(
                                      color: Default_Theme.primaryColor2
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Default_Theme.accentColor2,
                      thickness: 3,
                      height: 20,
                    ),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                searchFilter(value.toString());
              },
              style: TextStyle(
                color: Default_Theme.primaryColor1.withOpacity(0.55),
              ),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: Default_Theme.primaryColor2.withOpacity(0.07),
                contentPadding: const EdgeInsets.only(top: 20),
                hintText: "What you want to listen?",
                hintStyle: TextStyle(
                  color: Default_Theme.primaryColor1.withOpacity(0.4),
                  fontFamily: "Gilroy",
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Default_Theme.primaryColor1.withOpacity(0.7),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AddToPlaylistCubit, AddToPlaylistState>(
              builder: (context, state) {
                playlistsItems = state.playlists;
                // filteredPlaylistsItems = state.playlists;
                final _finalList =
                    filteredPlaylistsItems.isEmpty ||
                        _searchController.text.isEmpty
                    ? playlistsItems
                    : filteredPlaylistsItems;
                return ListView.builder(
                  itemCount: _finalList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 10),
                      child: InkWell(
                        onTap: () {
                          if (_finalList[index].playlistName != null &&
                              currentMediaModel != mediaItemModelNull) {
                            context.read<MediaDBCubit>().addMediaItemToPlaylist(
                              currentMediaModel,
                              MediaPlaylistDB(
                                playlistName: _finalList[index].playlistName!,
                              ),
                            );
                            context.pop(context);
                          }
                        },
                        child: SmallPlaylistCard(
                          playListTitle:
                              _finalList[index].playlistName ?? "Unknown",
                          coverArt: Image(
                            image: _finalList[index].imageProvider!,
                          ),
                          playListsubTitle:
                              _finalList[index].subTitle ?? "Unverified",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(
          FluentIcons.add_48_filled,
          size: 25,
          color: Default_Theme.primaryColor1,
        ),
        onPressed: () {
          createPlaylistBottomSheet(context);
        },
        label: const Text("Create New Playlist"),
      ),
    );
  }
}
