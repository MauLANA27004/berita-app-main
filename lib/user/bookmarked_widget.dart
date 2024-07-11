import 'package:berita_app/components/article_tile.dart';
import 'package:berita_app/models/news.dart';
import 'package:berita_app/user/news_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkedWidget extends StatelessWidget {
  const BookmarkedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(
        child: Text('Please sign in to view bookmarked news.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .orderBy('created_at', descending: true)
          .where('bookmarkedBy', arrayContains: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No news found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var news = snapshot.data!.docs[index];
            NewsModel newsModel = NewsModel.fromSnapshot(news);
            return ArticleTile(
              // isBookmarked: true,
              item_id: news.id,
              item: NewsModel.fromJson(news.data() as Map<String, dynamic>),
              onTap: () {
                // Handle tap on news item
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailPage(news: newsModel),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
