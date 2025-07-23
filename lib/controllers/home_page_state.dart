/// Manages the state of the home page
class HomePageState {
  bool _isLoading = true;
  bool _authFailed = false;
  String _authErrorMessage = '';

  /// Gets the current loading state
  bool get isLoading => _isLoading;

  /// Gets the authentication failure state
  bool get authFailed => _authFailed;

  /// Gets the authentication error message
  String get authErrorMessage => _authErrorMessage;

  /// Sets loading state
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  /// Sets authentication failure state
  void setAuthFailed(bool failed, [String message = '']) {
    _authFailed = failed;
    _authErrorMessage = message;
  }

  /// Resets all state to initial values
  void reset() {
    _isLoading = true;
    _authFailed = false;
    _authErrorMessage = '';
  }

  /// Sets successful initialization state
  void setInitialized() {
    _isLoading = false;
    _authFailed = false;
    _authErrorMessage = '';
  }
}
