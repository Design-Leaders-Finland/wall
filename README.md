# wall

> Write anonymous chat messages that have a max lenght of 160 characters, lifetime of 5 minutes, and can be seen by anyone else.

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/7f5b282964644331adf2295a81254267)](https://app.codacy.com/gh/Design-Leaders-Finland/wall/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Maintainability](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall/maintainability.svg)](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall)
[![Code Coverage](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall/coverage.svg)](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall)
[![Netlify Status](https://api.netlify.com/api/v1/badges/ab129df3-0fb9-48fe-a8fa-d50464ecc2f5/deploy-status)](https://wall.designleaders.fi)

```ps
# Build Android APK
flutter build apk --release
# Install it to Android emulator
flutter install
```

Icons generated with https://www.appiconly.com/

## Getting Started

### Install Dart and Flutter

[Install Flutter](https://docs.flutter.dev/get-started/install) (includes Dart):
   - Follow the instructions for your operating system.
   - After installation, run `flutter doctor` in your terminal to check for any missing dependencies.

### Local Development with Hot Reload

To start the app locally with hot reload:

```sh
flutter run
```

This will launch the app on your connected device or emulator. Save your changes to see them reflected instantly with hot reload.

## Quality Assurance

### Linting and Formatting

To check code quality and formatting, run:

```sh
flutter analyze
flutter format .
```

### Running Tests

To run all tests:

```sh
flutter test
```

Ensure all tests pass and address any issues reported by the analyzer before submitting changes.

## Documentation

### API Documentation

The project automatically generates comprehensive API documentation from code comments. The documentation is built and deployed to GitHub Pages as part of the CI/CD pipeline.

📚 **[View API Documentation](https://design-leaders-finland.github.io/wall/api-docs/)**

### Generating Documentation Locally

To generate the API documentation locally:

```sh
dart doc
```

This creates a `docs/` directory with the generated HTML documentation that you can open in your browser.

### Contributing to Documentation

When adding new classes, methods, or significant functionality:

1. Add comprehensive documentation comments using `///`
2. Include usage examples in code blocks
3. Document parameters, return values, and exceptions
4. Follow the [Dart documentation guidelines](https://dart.dev/effective-dart/documentation)

Example documentation format:
```dart
/// Brief description of the class or method.
/// 
/// More detailed explanation if needed. Can include multiple
/// paragraphs and markdown formatting.
/// 
/// ## Usage Example
/// ```dart
/// final service = MyService();
/// final result = await service.doSomething('parameter');
/// ```
/// 
/// **Parameters:**
/// - [parameter]: Description of what this parameter does
/// 
/// **Returns:** Description of the return value
/// 
/// **Throws:** [Exception] when something goes wrong
```
  
## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

