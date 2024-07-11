import 'package:berita_app/models/news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsModel news;

  NewsDetailPage({required this.news});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          news.thumbnail != null
              ? Image.network(news.thumbnail)
              : Container(height: 200, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            news.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('by ${news.author}'),
          SizedBox(height: 16),
          Text(news.content),
        ],
      ),
    );
  }
}
