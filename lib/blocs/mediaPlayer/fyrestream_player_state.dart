// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fyrestream_player_cubit.dart';

class FyreStreamPlayerState {
  bool isReady;
  bool showLyrics;
  FyreStreamPlayerState({required this.isReady, this.showLyrics = false});
}

final class FyreStreamPlayerInitial extends FyreStreamPlayerState {
  FyreStreamPlayerInitial() : super(isReady: false);
}

class ProgressBarStreams {
  late Duration currentPos;
  late PlaybackEvent currentPlaybackState;
  late PlayerState currentPlayerState;

  ProgressBarStreams({
    required this.currentPos,
    required this.currentPlaybackState,
    required this.currentPlayerState,
  });
}
