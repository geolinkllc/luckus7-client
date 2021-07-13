const flavor = String.fromEnvironment('flavor', defaultValue: 'prod');

bool get isDev => flavor == "dev";
bool get isProd => flavor == "prod";