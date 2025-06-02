class SessionManager {
  SessionManager._();
  static final SessionManager _instance = SessionManager._();
  static SessionManager get instance => _instance;

  int? _phone;
  String? _firstname;
  String? _lastname;
  String? _middlename;
  String? _email;

  int get phone {
    if (_phone == null) throw Exception("phone is NULL");
    return _phone!;
  }

  void setPhone(int phone) {
    _phone = phone;
  }

  String get getFirstname {
    if (_firstname == null) throw Exception("firstname is NULL");
    return _firstname!;
  }

  void setFirstname(String name) {
    _firstname = name;
  }

  String get getLastname {
    if (_lastname == null) throw Exception("lastname is NULL");
    return _lastname!;
  }

  void setLastname(String name) {
    _lastname = name;
  }

  String get getMiddlename {
    if (_middlename == null) throw Exception("middlename is NULL");
    return _middlename!;
  }

  void setMiddlename(String name) {
    _middlename = name;
  }

  String get getEmail {
    if (_email == null) throw Exception("email is NULL");
    return _email!;
  }

  void setEmail(String emailAddress) {
    _email = emailAddress;
  }
}
