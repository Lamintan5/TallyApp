class UserModel {
  String uid;
  String? username;
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? password;
  String? image;
  String? type;
  String? time;
  String? url;
  String? status;
  String? token;
  String? country;

  UserModel({required this.uid, this.username, this.firstname, this.lastname,this.email, this.phone ,this.type, this.password, this.token, this.image, this.status, this.url,this.time,this.country});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      username: json['username'] as String,
      firstname: json['first'] as String,
      lastname: json['last'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      image: json['image'] as String,
      status: json['status'] as String,
      token: json['token'] as String,
      country: json['country'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJsonAdd() {
    return {
      "uid":uid,
      "username" : username,
      "first" : firstname,
      "last" : lastname,
      "email" : email,
      "password" : password,
      "image" : image,
      "phone":phone,
      "time":time,
      "status":status,
      "token":token,
      "country":country,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      "uid" : uid,
      "username" : username,
      "first" : firstname,
      "last" : lastname,
      "phone":phone,
      "password":password,
    };
  }
}