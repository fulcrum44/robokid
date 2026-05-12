class AppConfig {
  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const compilerApiToken = String.fromEnvironment(
    'API_TOKEN',
    defaultValue: '',
  );
}