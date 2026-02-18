enum Environment { dev, prod }

class EnvConfig {
  static const Environment environment = Environment.dev;
  static const String apiUrl = environment == Environment.prod
      ? 'https://api.sweatcoin-india.com'
      : 'https://dev-api.sweatcoin-india.com';

  static const String appName = 'Sweatcoin India';
}
