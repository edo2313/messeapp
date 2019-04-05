
import 'package:http/http.dart' as http;

class LoginRegistro {


  static void makeLogin (String username, String password){
    Map<String, String> data = Map();
    data.putIfAbsent("uid", () => username);
    data.putIfAbsent("pwd", () => password);
    
    http.post('https://web.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd', body: data)
        .then((http.Response r) {
          //TODO: analizzare il body di r (JSON) e prendere il valore 'loggedIn'
          print(r.body);
        });
    
  }
}