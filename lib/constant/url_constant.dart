class UrlConstant {
  // static String host = "http://localhost:3001";

  // Ip addrees of the mac/window instead of localhost
  static String host = "http://192.168.10.204.:3001";

  static String signUp = "$host /api/signup";
  static String getUsers = "$host/api/get_users";

  static String createDocument = "$host/doc/create";
  static String getDocument = "$host/doc/me";

  static String updateDocument = "$host/doc/title";

  static String getDocumentById = "$host/doc/";
}
