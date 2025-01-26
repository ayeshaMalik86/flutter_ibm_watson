import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class IamOptions {
  late String iamApiKey;
  late String url;
  late String accessToken;
  late String refreshToken;
  late String tokenType;
  late int expiresIn;
  late int expiration;
  late String scope;

  IamOptions({required this.iamApiKey, required this.url});

  Future<IamOptions> build() async {

    Map datos = {
      "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
      "apikey": this.iamApiKey
    };
    var response = await http.post(
      "https://iam.bluemix.net/identity/token" as Uri,
      headers: {
        HttpHeaders.authorizationHeader: "Basic Yng6Yng=",
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        HttpHeaders.acceptHeader: "application/json",
      },
      body: datos,
    ).timeout(const Duration(seconds: 360));
    Map data = json.decode(response.body);
    this.accessToken = data["access_token"];
    this.refreshToken = data["refresh_token"];
    this.tokenType = data["token_type"];
    this.expiresIn = data["expires_in"];
    this.expiration = data["expiration"];
    this.scope = data["scope"];
    return this;
  }
}
