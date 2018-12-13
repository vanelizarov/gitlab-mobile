/*
"id": 4,
"description": null,
"default_branch": "master",
"ssh_url_to_repo": "git@example.com:diaspora/diaspora-client.git",
"http_url_to_repo": "http://example.com/diaspora/diaspora-client.git",
"web_url": "http://example.com/diaspora/diaspora-client",
"readme_url": "http://example.com/diaspora/diaspora-client/blob/master/README.md",
"tag_list": [
  "example",
  "disapora client"
],
"name": "Diaspora Client",
"name_with_namespace": "Diaspora / Diaspora Client",
"path": "diaspora-client",
"path_with_namespace": "diaspora/diaspora-client",
"created_at": "2013-09-30T13:46:02Z",
"last_activity_at": "2013-09-30T13:46:02Z",
"forks_count": 0,
"avatar_url": "http://example.com/uploads/project/avatar/4/uploads/avatar.png",
"star_count": 0,
*/

class Project {
  final int id;
  final String description;
  final String defaultBranch;
  final String sshUrlToRepo;
  final String httpUrlToRepo;
  final String webUrl;
  final String readmeUrl;
  final List<String> tagList;
  final String name;
  final String nameWithNamespace;
  final String path;
  final String pathWithNamespace;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final int forksCount;
  final String avatarUrl;
  final int starCount;

  Project({
    this.id,
    this.description,
    this.defaultBranch,
    this.sshUrlToRepo,
    this.httpUrlToRepo,
    this.webUrl,
    this.readmeUrl,
    this.tagList,
    this.name,
    this.nameWithNamespace,
    this.path,
    this.pathWithNamespace,
    this.createdAt,
    this.lastActivityAt,
    this.forksCount,
    this.avatarUrl,
    this.starCount,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      description: json['description'],
      defaultBranch: json['default_branch'],
      sshUrlToRepo: json['ssh_url_to_repo'],
      httpUrlToRepo: json['http_url_to_repo'],
      webUrl: json['web_url'],
      readmeUrl: json['readme_url'],
      tagList: json['tag_list'].map<String>((raw) => raw.toString()).toList(),
      name: json['name'],
      nameWithNamespace: json['name_with_namespace'],
      path: json['path'],
      pathWithNamespace: json['path_with_namespace'],
      createdAt: DateTime.parse(json['created_at']),
      lastActivityAt: DateTime.parse(json['last_activity_at']),
      forksCount: json['forks_count'],
      avatarUrl: json['avatar_url'],
      starCount: json['star_count'],
    );
  }

  @override
  String toString() {
    return 'Project[ id=$id, description=$description, defaultBranch=$defaultBranch, sshUrlToRepo=$sshUrlToRepo, httpUrlToRepo=$httpUrlToRepo, webUrl=$webUrl, readmeUrl=$readmeUrl, tagList=$tagList, name=$name, nameWithNamespace=$nameWithNamespace, path=$path, pathWithNamespace=$pathWithNamespace, createdAt=$createdAt, lastActivityAt=$lastActivityAt, forksCount=$forksCount, avatarUrl=$avatarUrl, starCount=$starCount ]';
  }
}
