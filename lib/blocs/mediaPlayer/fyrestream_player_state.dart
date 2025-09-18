// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fyrestream_player_cubit.dart';

class FyreStreamPlayerState {
  late bool isReady;

  FyreStreamPlayerState({required this.isReady});
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
