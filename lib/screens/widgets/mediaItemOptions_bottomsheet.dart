// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:fyrestream/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';

import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/routes_and_consts/global_str_consts.dart';
import 'package:fyrestream/theme_data/default.dart';
import 'package:fyrestream/utils/load_Image.dart';

void showMediaItemOptions(BuildContext context, MediaItemModel mediaItemModel) {
  showMaterialModalBottomSheet(
    context: context,
    expand: false,
    animationCurve: Curves.easeIn,
    duration: const Duration(milliseconds: 300),
    elevation: 20,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ClipRRect(
        // borderRadius: const BorderRadius.only(
        //     topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        child: Container(
          height: (MediaQuery.of(context).size.height * 0.45) + 10,
          color: Default_Theme.accentColor2,
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                // borderRadius: const BorderRadius.only(
                //     topLeft: Radius.circular(42),
                //     topRight: Radius.circular(42)),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  color: Default_Theme.themeColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: loadImageCached(
                                  mediaItemModel.artUri.toString(),
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
                                      mediaItemModel.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Default_Theme.secondoryTextStyle
                                          .merge(
                                            const TextStyle(
                                              color:
                                                  Default_Theme.primaryColor2,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                    ),
                                  ),
                                  Text(
                                    mediaItemModel.artist ?? "Unknown",
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(
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
                      InkWell(
                        onTap: () {
                          context
                              .read<AddToPlaylistCubit>()
                              .mediaItemModelBS
                              .add(mediaItemModel);
                          context.pushNamed(
                            GlobalStrConsts.addToPlaylistScreen,
                          );
                          context.pop(context);
                        },
                        child: const OptionIconBtn(
                          btnName: "Add to Playlist",
                          btnIconData: FluentIcons.library_24_filled,
                        ),
                      ),
                      const OptionIconBtn(
                        btnName: "Like",
                        btnIconData: FluentIcons.heart_48_regular,
                      ),
                      const OptionIconBtn(
                        btnName: "Save Offline",
                        btnIconData: FluentIcons.arrow_download_48_filled,
                      ),
                      const OptionIconBtn(
                        btnName: "Share with others",
                        btnIconData: FluentIcons.share_48_filled,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class OptionIconBtn extends StatelessWidget {
  final String btnName;
  final IconData btnIconData;

  const OptionIconBtn({
    Key? key,
    required this.btnName,
    required this.btnIconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 15, bottom: 5, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(btnIconData, size: 35, color: Default_Theme.primaryColor1),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Text(
              btnName,
              textAlign: TextAlign.center,
              style: Default_Theme.secondoryTextStyleMedium.merge(
                const TextStyle(
                  color: Default_Theme.primaryColor2,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
