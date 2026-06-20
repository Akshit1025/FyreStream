import 'package:fyrestream/services/fyrestreamPlayer.dart';
import 'package:fyrestream/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() {
    return _instance;
  }
  static late FyreStreamMusicPlayer fyrestreamPlayer;

  PlayerInitializer._internal();

  static bool _isInitialized = false;

  Future<void> _initialize() async {
    fyrestreamPlayer = await AudioService.init(
      builder: () => FyreStreamMusicPlayer(),
      config: const AudioServiceConfig(
          androidStopForegroundOnPause: false,
          androidNotificationChannelId: 'com.FyreStreamPlayer.notification.status',
          androidNotificationChannelName: 'FyreStream',
          androidResumeOnClick: true,
          // androidNotificationIcon: 'assets/icons/fyrestream_new_logo_transparent_c.png',
          androidShowNotificationBadge: true,
          notificationColor: Default_Theme.accentColor2),
    );
  }

  Future<FyreStreamMusicPlayer> getPlayer() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
    return fyrestreamPlayer;
  }
}