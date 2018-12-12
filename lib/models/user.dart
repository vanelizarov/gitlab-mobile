enum UserState { active, blocked }

class User {
  final int id;
  final String name;
  final String username;
  final UserState state;
  final String avatarUrl;
  final String webUrl;
  final DateTime createdAt;
  final String bio;
  final DateTime lastSignInAt;
  final DateTime confirmedAt;
  final DateTime lastActivityOn;
  final String email;
  final DateTime currentSignInAt;

  User({
    this.id,
    this.name,
    this.username,
    this.state,
    this.avatarUrl,
    this.webUrl,
    this.createdAt,
    this.bio,
    this.lastSignInAt,
    this.confirmedAt,
    this.lastActivityOn,
    this.email,
    this.currentSignInAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      state: json['state'] == 'active' ? UserState.active : UserState.blocked,
      avatarUrl: json['avatar_url'],
      webUrl: json['web_url'],
      createdAt: DateTime.parse(json['created_at']),
      bio: json['bio'],
      lastSignInAt: DateTime.parse(json['last_sign_in_at']),
      confirmedAt: DateTime.parse(json['confirmed_at']),
      lastActivityOn: DateTime.parse(json['last_activity_on']),
      email: json['email'],
      currentSignInAt: DateTime.parse(json['current_sign_in_at']),
    );
  }

  @override
  String toString() {
    return 'User[ id=$id, name=$name, username=$username, state=$state, avatarUrl=$avatarUrl, webUrl=$webUrl, createdAt=$createdAt, bio=$bio, lastSignInAt=$lastSignInAt, confirmedAt=$confirmedAt, lastActivityOn=$lastActivityOn, email=$email, currentSignInAt=$currentSignInAt ]';
  }
}
