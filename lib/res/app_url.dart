class AppUrl {

  // static var baseUrl = 'https://app.attendly.ai'; /// Live Server
  static var baseUrl = 'https://dev.attendly.ai' ;  /// dev Server

  static var loginEndPint = baseUrl + '/api/app/login';


  static var registerApiEndPoint = baseUrl + '/api/app/register';

  static var logOutEndPoint = baseUrl + '/api/app/logout';

  static var staffDriver = baseUrl + '/uploads/driver';
  static var staffUsers = baseUrl + '/uploads/users';

  static var clientDrivers = baseUrl + '/uploads/driver';
  static var clientUsers = baseUrl + '/uploads/users';
}
