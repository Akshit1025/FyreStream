import 'package:fyrestream/blocs/album_view/album_cubit.dart';
import 'package:fyrestream/blocs/mediaPlayer/fyrestream_player_cubit.dart';
import 'package:fyrestream/model/album_onl_model.dart';
import 'package:fyrestream/model/source_engines.dart';
import 'package:fyrestream/screens/widgets/more_bottom_sheet.dart';
import 'package:fyrestream/screens/widgets/snackbar.dart';
import 'package:fyrestream/screens/widgets/song_tile.dart';
import 'package:fyrestream/theme_data/default.dart';
import 'package:fyrestream/utils/imgurl_formator.dart';
import 'package:fyrestream/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class AlbumView extends StatefulWidget {
  final AlbumModel album;
  const AlbumView({super.key, required this.album});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  late AlbumCubit albumCubit;
  @override
  void initState() {
    albumCubit = AlbumCubit(
      album: widget.album,
      sourceEngine: widget.album.source == 'saavn'
          ? SourceEngine.eng_JIS
          : SourceEngine.eng_YTM,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<AlbumCubit, AlbumState>(
          bloc: albumCubit,
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight:
                  ResponsiveBreakpoints.of(context).isMobile ? 220 : 250,
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    String subtitle = widget.album.year;
                    if (widget.album.genre != null &&
                        widget.album.genre != "Unknown") {
                      subtitle += ' - ${widget.album.genre!}';
                    }
                    if (widget.album.language != null) {
                      subtitle += ' - ${widget.album.language!}';
                    }

                    return FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 34,
                          bottom: 8,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight,
                            minWidth: 350,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                  MediaQuery.of(context).size.width * 0.4,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Hero(
                                      tag: widget.album.sourceId,
                                      child: LoadImageCached(
                                        imageUrl: formatImgURL(
                                            widget.album.imageURL,
                                            ImageQuality.medium),
                                      )),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Album by",
                                        style: Default_Theme
                                            .secondoryTextStyleMedium
                                            .merge(
                                          TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14,
                                            color: Default_Theme.primaryColor1
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget.album.artists,
                                        maxLines: 3,
                                        style: Default_Theme
                                            .secondoryTextStyleMedium
                                            .merge(
                                          TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14,
                                            color: Default_Theme.primaryColor1
                                                .withOpacity(0.9),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        subtitle,
                                        style: Default_Theme.secondoryTextStyle
                                            .merge(
                                          TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 13,
                                            color: Default_Theme.primaryColor1
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(top: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    width: 2,
                                                    color: Default_Theme
                                                        .accentColor2,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (context
                                                      .read<
                                                      FyrestreamPlayerCubit>()
                                                      .fyrestreamPlayer
                                                      .queueTitle
                                                      .value !=
                                                      widget.album.name) {
                                                    context
                                                        .read<
                                                        FyrestreamPlayerCubit>()
                                                        .fyrestreamPlayer
                                                        .loadPlaylist(
                                                        state
                                                            .album.playlist,
                                                        doPlay: true,
                                                        idx: 0);
                                                  } else if (!context
                                                      .read<
                                                      FyrestreamPlayerCubit>()
                                                      .fyrestreamPlayer
                                                      .audioPlayer
                                                      .playing) {
                                                    context
                                                        .read<
                                                        FyrestreamPlayerCubit>()
                                                        .fyrestreamPlayer
                                                        .play();
                                                  }
                                                },
                                                label: const Text(
                                                  "Play",
                                                  style: Default_Theme
                                                      .secondoryTextStyleMedium,
                                                ),
                                                icon: const Icon(
                                                  MingCute.play_fill,
                                                  size: 20,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 5,
                                                ),
                                                child: Tooltip(
                                                  message: "Open Original Link",
                                                  child: IconButton(
                                                    onPressed: () {
                                                      SnackbarService.showMessage(
                                                          "Opening original album page.");
                                                      launchUrl(
                                                          Uri.parse(state
                                                              .album.sourceURL),
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    },
                                                    icon: const Icon(
                                                      MingCute
                                                          .external_link_line,
                                                      size: 25,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: Text(
                      widget.album.name,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: Default_Theme.secondoryTextStyleMedium.merge(
                        TextStyle(
                          fontSize: 20,
                          color: Default_Theme.primaryColor1.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
                (state is AlbumLoaded)
                    ? SliverList.builder(
                    itemBuilder: (context, index) {
                      return SongCardWidget(
                        song: state.album.songs[index],
                        onOptionsTap: () {
                          showMoreBottomSheet(
                              context, state.album.songs[index],
                              showDelete: false);
                        },
                        onTap: () {
                          if (context
                              .read<FyrestreamPlayerCubit>()
                              .fyrestreamPlayer
                              .queueTitle
                              .value !=
                              widget.album.name ||
                              context
                                  .read<FyrestreamPlayerCubit>()
                                  .fyrestreamPlayer
                                  .currentMedia !=
                                  state.album.songs[index]) {
                            context
                                .read<FyrestreamPlayerCubit>()
                                .fyrestreamPlayer
                                .loadPlaylist(state.album.playlist,
                                doPlay: true, idx: index);
                          } else if (!context
                              .read<FyrestreamPlayerCubit>()
                              .fyrestreamPlayer
                              .audioPlayer
                              .playing) {
                            context
                                .read<FyrestreamPlayerCubit>()
                                .fyrestreamPlayer
                                .play();
                          }
                        },
                      );
                    },
                    itemCount: state.album.songs.length)
                    : const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}