class ApiError {
  final String message;

  ApiError({this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(message: json['message']);
  }

  @override
  String toString() => 'ApiError[ message=$message ]';
}
