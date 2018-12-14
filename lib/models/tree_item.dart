enum TreeItemType { tree, blob }

class TreeItem {
  final String id;
  final String name;
  final TreeItemType type;
  final String path;

  TreeItem({
    this.id,
    this.name,
    this.type,
    this.path,
  });

  factory TreeItem.fromJson(Map<String, dynamic> json) {
    return TreeItem(
      id: json['id'],
      name: json['name'],
      type: json['type'] == 'tree' ? TreeItemType.tree : TreeItemType.blob,
      path: json['path'],
    );
  }

  @override
  String toString() => 'TreeItem[ id=$id, name=$name, type=$type, path=$path ]';
}
