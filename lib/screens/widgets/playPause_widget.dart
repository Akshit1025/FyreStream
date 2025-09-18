// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:fyrestream/theme_data/default.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  bool isPlaying;

  PlayPauseButton({
    Key? key,
    this.size = 60,
    this.onPlay,
    this.onPause,
    this.isPlaying = false,
  }) : super(key: key);

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late bool _isPlaying;
  late Color _currentColor;

  void _togglePlayPause() {
    print(_isPlaying);
    setState(() {
      _isPlaying ? widget.onPause!() : widget.onPlay!();
      _isPlaying = !_isPlaying;
      _currentColor = _isPlaying
          ? Default_Theme.accentColor1
          : Default_Theme.accentColor2;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _size = widget.size;
    _isPlaying = widget.isPlaying;
    _currentColor = _isPlaying
        ? Default_Theme.accentColor1
        : Default_Theme.accentColor2;
    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: _currentColor, spreadRadius: 1, blurRadius: 20),
            ],
            shape: BoxShape.circle,
            color: _currentColor,
          ),
          width: _size,
          height: _size,
          child: _isPlaying
              ? const Icon(
                  FluentIcons.pause_48_filled,
                  size: 35,
                  color: Default_Theme.primaryColor1,
                )
              : const Icon(
                  FluentIcons.play_48_filled,
                  size: 35,
                  color: Default_Theme.primaryColor1,
                ),
        ),
      ),
    );
  }
}
