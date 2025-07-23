/// Manages connection state and offline/online mode
class ConnectionManager {
  bool _isOffline = false;
  int _localMessageCount = 0;

  /// Gets the current offline status
  bool get isOffline => _isOffline;

  /// Gets the count of local messages
  int get localMessageCount => _localMessageCount;

  /// Updates the connection state
  void updateConnectionState({
    required bool isOffline,
    int localMessageCount = 0,
  }) {
    _isOffline = isOffline;
    _localMessageCount = localMessageCount;
  }

  /// Sets offline mode with message count
  void setOfflineMode(int messageCount) {
    _isOffline = true;
    _localMessageCount = messageCount;
  }

  /// Sets online mode
  void setOnlineMode() {
    _isOffline = false;
    _localMessageCount = 0;
  }

  /// Gets display text for offline indicator
  String getOfflineDisplayText() {
    return _localMessageCount > 0 ? 'OFFLINE ($_localMessageCount)' : 'OFFLINE';
  }
}
