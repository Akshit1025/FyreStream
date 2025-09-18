import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:fyrestream/services/db/MediaDB.dart';
import 'package:fyrestream/services/db/cubit/mediadb_cubit.dart';
import 'package:fyrestream/theme_data/default.dart';

void createPlaylistBottomSheet(BuildContext context) {
  final _focusNode = FocusNode();
  showMaterialModalBottomSheet(
    context: context,
    expand: false,
    animationCurve: Curves.easeIn,
    duration: const Duration(milliseconds: 300),
    elevation: 20,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: Container(
          height: (MediaQuery.of(context).size.height * 0.45) + 10,
          color: Default_Theme.accentColor2,
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                  child: Container(
                    color: Default_Theme.themeColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 30,
                            ),
                            child: Text(
                              "Create new Playlist 😍",
                              style: Default_Theme.secondoryTextStyleMedium
                                  .merge(
                                    const TextStyle(
                                      color: Default_Theme.accentColor2,
                                      fontSize: 35,
                                    ),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                            ),
                            child: TextField(
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              maxLines: 3,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              focusNode: _focusNode,
                              cursorHeight: 50,
                              showCursor: true,
                              cursorWidth: 5,
                              cursorRadius: const Radius.circular(5),
                              cursorColor: Default_Theme.accentColor2,
                              style: const TextStyle(
                                fontSize: 45,
                                color: Default_Theme.accentColor2,
                              ).merge(Default_Theme.secondoryTextStyleMedium),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    style: BorderStyle.none,
                                  ),
                                  // borderRadius: BorderRadius.circular(50)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  // borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onTapOutside: (event) {
                                _focusNode.unfocus();
                              },
                              onSubmitted: (value) {
                                _focusNode.unfocus();
                                print(value);
                                if (value.isNotEmpty && value.length > 2) {
                                  context
                                      .read<MediaDBCubit>()
                                      .addNewPlaylistToDB(
                                        MediaPlaylistDB(playlistName: value),
                                      );
                                  context.pop();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
