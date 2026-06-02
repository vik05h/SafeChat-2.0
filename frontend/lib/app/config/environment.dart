enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final String baseUrl;
  final Environment environment;

  AppConfig({required this.baseUrl, required this.environment});

  static AppConfig get env {
    const String envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    
    switch (envString) {
      case 'prod':
        return AppConfig(
          baseUrl: 'https://safechat-backend-275978897008.us-central1.run.app/api/v1',
          environment: Environment.prod,
        );
      case 'staging':
        return AppConfig(
          baseUrl: 'https://safechat-backend-275978897008.us-central1.run.app/api/v1',
          environment: Environment.staging,
        );
      case 'dev':
      default:
        return AppConfig(
          // Use 10.0.2.2 for Android emulator pointing to localhost
          baseUrl: 'http://10.0.2.2:8000/api/v1',
          environment: Environment.dev,
        );
    }
  }
}
