import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class NewsModel {
    String author;
    String content;
    Timestamp created_at;
    String thumbnail;
    String title;
    List<String> bookmarkedBy;

    NewsModel({
        required this.author,
        required this.content,
        required this.created_at,
        required this.thumbnail,
        required this.title,
        required this.bookmarkedBy,
    });

    NewsModel copyWith({
        String? author,
        String? content,
        Timestamp? created_at,
        String? thumbnail,
        String? title,
        List<String>? bookmarkedBy,
    }) => 
        NewsModel(
            author: author ?? this.author,
            content: content ?? this.content,
            created_at: created_at ?? this.created_at,
            thumbnail: thumbnail ?? this.thumbnail,
            title: title ?? this.title,
            bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
        );

    factory NewsModel.fromRawJson(String str) => NewsModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        author: json["author"],
        content: json["content"],
        created_at: json["created_at"],
        thumbnail: json["thumbnail"],
        title: json["title"],
        bookmarkedBy: List<String>.from(json["bookmarkedBy"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "author": author,
        "content": content,
        "created_at": created_at,
        "thumbnail": thumbnail,
        "title": title,
        "bookmarkedBy": List<dynamic>.from(bookmarkedBy.map((x) => x)),
    };

    static NewsModel fromSnapshot(DocumentSnapshot snapshot) {
        var data = snapshot.data() as Map<String, dynamic>;
        return NewsModel(
            author: data["author"],
            content: data["content"],
            created_at: data["created_at"],
            thumbnail: data["thumbnail"],
            title: data["title"],
            bookmarkedBy: List<String>.from(data["bookmarkedBy"].map((x) => x)),
        );
    }
}
