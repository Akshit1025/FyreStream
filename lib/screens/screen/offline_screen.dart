import 'package:fyrestream/blocs/library/cubit/library_items_cubit.dart';
import 'package:fyrestream/blocs/mediaPlayer/fyrestream_player_cubit.dart';
import 'package:fyrestream/blocs/offline/offline_cubit.dart';
import 'package:fyrestream/model/MediaPlaylistModel.dart';
import 'package:fyrestream/screens/widgets/more_bottom_sheet.dart';
import 'package:fyrestream/screens/widgets/sign_board_widget.dart';
import 'package:fyrestream/screens/widgets/song_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:fyrestream/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OfflineCubit(libraryItemsCubit: context.read<LibraryItemsCubit>()),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            customDiscoverBar(context), //AppBar
            SliverList(
                delegate: SliverChildListDelegate([
                  BlocBuilder<OfflineCubit, OfflineState>(
                      builder: (context, state) {
                        if (state is OfflineInitial) {
                          return const CircularProgressIndicator();
                        } else if (state is OfflineEmpty) {
                          return const SignBoardWidget(
                            message: "No Downloads",
                            icon: FontAwesome.download_solid,
                          );
                        } else {
                          return Column(
                            children: state.songs
                                .map((e) => SongCardWidget(
                              song: e,
                              showOptions: true,
                              delDownBtn: true,
                              onTap: () {
                                context
                                    .read<FyrestreamPlayerCubit>()
                                    .fyrestreamPlayer
                                    .loadPlaylist(
                                    MediaPlaylist(
                                        mediaItems: state.songs,
                                        albumName: "Offline"),
                                    idx: state.songs.indexOf(e),
                                    doPlay: true);
                              },
                              onOptionsTap: () {
                                showMoreBottomSheet(context, e,
                                    showDelete: false);
                              },
                            ))
                                .toList(),
                          );
                        }
                      })
                ]))
          ],
        ),
        backgroundColor: Default_Theme.themeColor,
      ),
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
          Text("Offline",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          // IconButton(
          //     onPressed: () {
          //       context.read<OfflineCubit>().getSongs();
          //     },
          //     icon: const Icon(MingCute.refresh_1_line)),
        ],
      ),
    );
  }
}