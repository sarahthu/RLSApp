import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterapp/dio_setup.dart';

class JwtService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  //--------- Methode um Token im SecureStorage zu speichern --------------------------------------------
  Future<void> saveToken(String tokenString) async {
    await _storage.write(key: 'jwt', value: tokenString); //speichert erhaltenes Token als String in securestorage
  }

  //--------- Method um Tokens aus dem SecureStorage zu holen --------------------------------------------
  Future<String?> getToken() async {
    final tokenString = await _storage.read(key: 'jwt'); //halt Token als String aus securestorage
    if (tokenString != null){
      final Map<String, dynamic> tokenJson = jsonDecode(tokenString); //konvertiert den String in eine JSON
      return tokenJson["access"]; //gibt von dieser Json das element mit dem key "access" = das access token zurück
    }
    else{
      return null;
    }
  }

  //--------- Methode um Token aus dem SecureStorage zu löschen --------------------------------------------
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt');
  }

  //--------- Methode für User Login -----------------------------------------------------------------
  Future<bool> login(String username, String password) async {
    try {
      final response = await dio.post("/token/",   //verwendet dio das in dio_setup erstellt wurde
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final tokenJson = response.data; //speichert erhaltene Antwort in Variable tokenJson
        if (tokenJson != null) {
          String tokenString = jsonEncode(tokenJson); //konvertiert erhaltene JSON in einen String
          await saveToken(tokenString); //sendet String zum Speichern an saveToken Methode
          return true;
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  //--------- Method für Registrierung von neuen Benutzern --------------------------------------------
  Future<bool> signup(String username, String password) async {
    try {
      final response = await dio.post("/register/",
            data: {"username": username, "password": password},
      );

      if (response.statusCode == 201) {
        final resp = response.data; // Ensure this matches your API response
        if (resp != null) {
          return true;
        }
      }

      if (response.statusCode == 400) {
        final resp = response.data; // Ensure this matches your API response
        if (resp != null) {
          return true;
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Fehlertext vom Backend
        print('Status: ${e.response!.statusCode}');
        print('Fehlerdaten: ${e.response!.data}');
      } else {
        // Kein Server erreicht
        print('Request error: ${e.message}');
      }
      print('Signup error: $e');
    }
    return false;
  }

  //--------- Methode für User Logout ----------------------------------------------------------------
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }
}