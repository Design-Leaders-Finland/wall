import 'package:flutter_test/flutter_test.dart';
import 'package:wall/controllers/home_page_state.dart';

void main() {
  group('HomePageState Tests', () {
    late HomePageState homePageState;

    setUp(() {
      homePageState = HomePageState();
    });

    group('Initial State', () {
      test('should start in loading state', () {
        // Assert
        expect(homePageState.isLoading, isTrue);
        expect(homePageState.authFailed, isFalse);
        expect(homePageState.authErrorMessage, isEmpty);
      });
    });

    group('Loading State Management', () {
      test('should set loading state correctly', () {
        // Act
        homePageState.setLoading(false);

        // Assert
        expect(homePageState.isLoading, isFalse);
      });

      test('should toggle loading state', () {
        // Arrange
        homePageState.setLoading(false);

        // Act
        homePageState.setLoading(true);

        // Assert
        expect(homePageState.isLoading, isTrue);
      });
    });

    group('Authentication State Management', () {
      test('should set auth failed state with message', () {
        // Act
        homePageState.setAuthFailed(true, 'Test error message');

        // Assert
        expect(homePageState.authFailed, isTrue);
        expect(homePageState.authErrorMessage, equals('Test error message'));
      });

      test('should set auth failed state without message', () {
        // Act
        homePageState.setAuthFailed(true);

        // Assert
        expect(homePageState.authFailed, isTrue);
        expect(homePageState.authErrorMessage, isEmpty);
      });

      test('should clear auth failed state', () {
        // Arrange
        homePageState.setAuthFailed(true, 'Error');

        // Act
        homePageState.setAuthFailed(false);

        // Assert
        expect(homePageState.authFailed, isFalse);
        expect(homePageState.authErrorMessage, isEmpty);
      });
    });

    group('State Reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        homePageState.setLoading(false);
        homePageState.setAuthFailed(true, 'Error message');

        // Act
        homePageState.reset();

        // Assert
        expect(homePageState.isLoading, isTrue);
        expect(homePageState.authFailed, isFalse);
        expect(homePageState.authErrorMessage, isEmpty);
      });
    });

    group('Successful Initialization', () {
      test('should set initialized state correctly', () {
        // Arrange
        homePageState.setAuthFailed(true, 'Error');

        // Act
        homePageState.setInitialized();

        // Assert
        expect(homePageState.isLoading, isFalse);
        expect(homePageState.authFailed, isFalse);
        expect(homePageState.authErrorMessage, isEmpty);
      });
    });
  });
}
