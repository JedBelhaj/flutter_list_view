class ApiConfig {
  // Override at run time with:
  // flutter run --dart-define=API_BASE_URL=http://<your-ip>/user
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.18.133.31/user',
  );
  static const String addUserUrl = "$baseUrl/add_user.php";
  static const String getUsersUrl = "$baseUrl/get_all_users.php";
}
