class ResponseModel {
  bool success;
  String message;
  dynamic data;

  ResponseModel(this.success, this.message, {this.data});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      json['success'] ?? false,
      json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}