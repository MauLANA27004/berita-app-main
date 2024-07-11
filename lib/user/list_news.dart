import 'package:berita_app/components/article_tile.dart';
import 'package:berita_app/components/big_article_tile.dart';
import 'package:berita_app/models/news.dart';
import 'package:berita_app/user/news_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class ListNews extends StatefulWidget {
  const ListNews({super.key});

  @override
  State<ListNews> createState() => _ListNewsState();
}

class _ListNewsState extends State<ListNews> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .orderBy('created_at', descending: true)
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
            NewsModel newsModel =
                NewsModel.fromSnapshot(snapshot.data!.docs[index]);

            if (index == 0) {
              return Container(
                width: screenSize.width - 50,
                margin: EdgeInsets.all(5),
                child: BigArticleTile(
                  news: newsModel,
                  size: screenSize,
                  onTap: () => navigateToDetailNews(newsModel),
                  bookmarkOnTap: () => toggleBookmark(newsModel, news.id),
                ),
              );
            }

            return ArticleTile(
              item_id: news.id,
              item: newsModel,
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

  void navigateToDetailNews(NewsModel newsModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(news: newsModel),
      ),
    );
  }

  void toggleBookmark(newsModel, item_id) async {
    // Check if user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Navigate to login page if not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login first')),
        );
      return;
    }

    // Perform Firestore operations to save or remove bookmark
    try {
      final CollectionReference bookmarksRef = FirebaseFirestore.instance
          .collection('news')
          .doc(item_id)
          .collection('bookmarks');

      if (!newsModel.bookmarkedBy.contains(user.uid)) {
        // Add bookmark and update 'bookmarkedBy' field
        await bookmarksRef.doc(user.uid).set({
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update 'bookmarkedBy' in main news document
        await FirebaseFirestore.instance
            .collection('news')
            .doc(item_id)
            .update({
          'bookmarkedBy': FieldValue.arrayUnion([user.uid]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('News bookmarked')),
        );
      } else {
        // Remove bookmark and update 'bookmarkedBy' field
        await bookmarksRef.doc(user.uid).delete();

        // Update 'bookmarkedBy' in main news document
        await FirebaseFirestore.instance
            .collection('news')
            .doc(item_id)
            .update({
          'bookmarkedBy': FieldValue.arrayRemove([user.uid]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmark removed')),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('fail, somethings wrong')),
        );
      }
    }
  }
}
