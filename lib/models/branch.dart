class Branch {
  final String name;

  Branch({this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(name: json['name']);
  }

  @override
  String toString() => 'Branch[ name=$name ]';
}
