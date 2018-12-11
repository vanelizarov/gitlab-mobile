class Token {
  static final Token _instance = Token._();

  String value;

  factory Token() => _instance;

  Token._();
}
