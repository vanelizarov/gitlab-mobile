/*
{
  "file_name": "key.rb",
  "file_path": "app/models/key.rb",
  "size": 1476,
  "encoding": "base64",
  "content": "IyA9PSBTY2hlbWEgSW5mb3...",
  "content_sha256": "4c294617b60715c1d218e61164a3abd4808a4284cbc30e6728a01ad9aada4481",
  "ref": "master",
  "blob_id": "79f7bbd25901e8334750839545a9bd021f0e4c83",
  "commit_id": "d5a3ff139356ce33e37e73add446f16869741b50",
  "last_commit_id": "570e7b2abdd848b95f2f578043fc23bd6f6fd24d"
}
*/

enum FileEncoding { base64 }

class File {
  final String name;
  final String path;
  final int size;
  final FileEncoding encoding;
  final String content;
  final String contentSha256;
  final String ref;
  final String blobId;
  final String commitId;
  final String lastCommitId;

  File({
    this.name,
    this.path,
    this.size,
    this.encoding,
    this.content,
    this.contentSha256,
    this.ref,
    this.blobId,
    this.commitId,
    this.lastCommitId,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      name: json['file_name'],
      path: json['file_path'],
      size: json['size'],
      encoding: FileEncoding.base64,
      content: json['content'],
      contentSha256: json['content_sha256'],
      ref: json['ref'],
      blobId: json['blob_id'],
      commitId: json['commit_id'],
      lastCommitId: json['last_commit_id'],
    );
  }

  @override
  String toString() =>
      'File[ path=$path, name=$name, size=$size, encoding=$encoding, content=$content, contentSha256=$contentSha256, ref=$ref, blobId=$blobId, commitId=$commitId, lastCommitId=$lastCommitId ]';
}
