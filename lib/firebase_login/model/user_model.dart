class DBUser{
  String uid;
  String email;
  String password;
  String userdept;
  String usergrade;
  String username;
  double usage;

  DBUser({
    this.uid = '',
    this.email = '',
    this.password = '',
    this.userdept = '',
    this.usergrade = '',
    this.username = '',
    this.usage = 0
  });

  factory DBUser.fromFireStore(Map<String, dynamic> data) {
    return DBUser(
      email: data['email'],
      userdept: data['userdept'],
      usergrade: data['usergrade'],
      username: data['username'],
      usage: data['usage'],
    );
  }

  Map<String, String> toJson() => {
    'uid' : uid,
    'email' : email,
    'password' : password,
    'username' : username,
    'userdept' : userdept,
    'usergrade' : usergrade,
  };

  static DBUser getInstance(){
    return DBUser(email: '', userdept: '', usergrade: '', username: '', usage: 0);
  }
}