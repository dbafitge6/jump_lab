import 'package:share_plus/share_plus.dart' show Share;
import 'package:shared_preferences/shared_preferences.dart';

class ShareManager {
  static final ShareManager instance = ShareManager._init();
  ShareManager._init();

  static const String _key = 'has_shared';
  bool _hasShared = false;

  bool get hasShared => _hasShared;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasShared = prefs.getBool(_key) ?? false;
  }

  Future<void> shareApp() async {
    const text = 'JumpLabでジャンプ力を計測しよう！ #ジャンプラボ\nhttps://apps.apple.com/app/id6772440429';
    await Share.share(text);
    await _setShared();
  }

  Future<void> _setShared() async {
    _hasShared = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
