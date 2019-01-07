enum BlobType { tree, blob }

class Blob {
  final String id;
  final String name;
  final BlobType type;
  final String path;

  Blob({
    this.id,
    this.name,
    this.type,
    this.path,
  });

  factory Blob.fromJson(Map<String, dynamic> json) {
    return Blob(
      id: json['id'],
      name: json['name'],
      type: json['type'] == 'tree' ? BlobType.tree : BlobType.blob,
      path: json['path'],
    );
  }

  @override
  String toString() => 'TreeItem[ id=$id, name=$name, type=$type, path=$path ]';
}
