import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TranslationResult {
  late int wordCount;
  late int characterCount;
  late dynamic translations;

  TranslationResult(Map result) {
    translations = result["translations"];
    wordCount = result["word_count"];
    characterCount = result["character_count"];
  }

  String toString() {
    return translations[0]["translation"];
  }

  int getWordCount() {
    return this.wordCount;
  }

  int getCharacterCount() {
    return this.translations;
  }
}

class ItemIdentifyLanguageResult {
  double confidence;
  String language;

  ItemIdentifyLanguageResult(
      {required this.confidence, required this.language});

  @override
  String toString() {
    // TODO: implement toString
    return json
        .encode({"language": this.language, "condidence": this.confidence});
  }
}

class IdentifyLanguageResult {
  late List<ItemIdentifyLanguageResult> _list;

  IdentifyLanguageResult() {
    this._list = List<ItemIdentifyLanguageResult>.empty(growable: true);
  }

  void add(ItemIdentifyLanguageResult item) {
    this._list.add(item);
  }

  String getLanguageProbability() {
    if (this._list.length < 1) {
      return "";
    }
    return this._list.elementAt(0).language;
  }

  List<ItemIdentifyLanguageResult> getAllLanguageProbability() {
    return this._list;
  }

  @override
  String toString() {
    // TODO: implement toString
    return getLanguageProbability();
  }
}

class LanguageTranslator {
  late String urlBase =
      "https://gateway.watsonplatform.net/language-translator/api";
  late String modelId;
  late final String version;
  late IamOptions iamOptions;

  LanguageTranslator({
    required this.iamOptions,
    this.version = "2018-05-01",
  });

  String _getUrl(method) {
    String url = iamOptions.url;
    if (iamOptions.url == "" || iamOptions.url == null) {
      url = urlBase;
    }
    return "$url/v3/$method?version=$version";
  }

  Future<TranslationResult> translate(
      String text, String source, String target) async {
    String token = this.iamOptions.accessToken;
    modelId = source + "-" + target;
    var response = await http
        .post(
          _getUrl("translate") as Uri,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
          },
          body: '{\"text\":[\"$text\"],\"model_id\":\"$modelId\"}',
        )
        .timeout(const Duration(seconds: 360));
    return new TranslationResult(json.decode(response.body));
  }

  Future<IdentifyLanguageResult> identifylanguage(String text) async {
    IdentifyLanguageResult identifyLanguageResult =
        new IdentifyLanguageResult();
    String token = this.iamOptions.accessToken;
    var response = await http
        .post(
          _getUrl("identify") as Uri,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "text/plain",
          },
          body: text,
        )
        .timeout(const Duration(seconds: 360));
    Map result = json.decode(response.body);
    dynamic languages = result["languages"];
    List<dynamic> listLanguages = languages;
    for (int i = 0; i < listLanguages.length; i++) {
      Map language = listLanguages[0];
      identifyLanguageResult.add(new ItemIdentifyLanguageResult(
          confidence: language["confidence"], language: language["language"]));
    }
    return identifyLanguageResult;
  }
}
