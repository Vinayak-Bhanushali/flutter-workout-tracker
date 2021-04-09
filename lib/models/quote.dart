import 'package:meta/meta.dart';
import 'dart:convert';

class Quote {
  Quote({
    @required this.quoteText,
    @required this.quoteAuthor,
    @required this.senderName,
    @required this.senderLink,
    @required this.quoteLink,
  });

  final String quoteText;
  final String quoteAuthor;
  final String senderName;
  final String senderLink;
  final String quoteLink;

  factory Quote.fromRawJson(String str) => Quote.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Quote.fromJson(Map<String, dynamic> json) {
    if (json["quoteText"] != null && json["quoteText"] is String) {
      json["quoteText"] = json["quoteText"].trim();
      if (json["quoteText"].endsWith('.')) {
        json["quoteText"] =
            json["quoteText"].substring(0, json["quoteText"].length - 1);
      }
    }
    return Quote(
      quoteText: json["quoteText"] == null ? null : json["quoteText"],
      quoteAuthor: json["quoteAuthor"] == null ? null : json["quoteAuthor"],
      senderName: json["senderName"] == null ? null : json["senderName"],
      senderLink: json["senderLink"] == null ? null : json["senderLink"],
      quoteLink: json["quoteLink"] == null ? null : json["quoteLink"],
    );
  }

  Map<String, dynamic> toJson() => {
        "quoteText": quoteText == null ? null : quoteText,
        "quoteAuthor": quoteAuthor == null ? null : quoteAuthor,
        "senderName": senderName == null ? null : senderName,
        "senderLink": senderLink == null ? null : senderLink,
        "quoteLink": quoteLink == null ? null : quoteLink,
      };
}
