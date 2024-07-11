import 'package:berita_app/components/image_card.dart';
import 'package:berita_app/models/news.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class BigArticleTile extends StatelessWidget {
  final NewsModel news;
  final Size size;
  final VoidCallback? onTap;
  final VoidCallback? bookmarkOnTap;

  const BigArticleTile(
      {Key? key,
      required this.news,
      required this.size,
      required this.onTap,
      this.bookmarkOnTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      child: ImageCard(
        imageUrl: this.news.thumbnail,
        title: this.news.title,
        description:
            "${news.author} · ${timeago.format(news.created_at.toDate())}",
        bookmarkOnTap: bookmarkOnTap,
        isBookmark: getIsBookmarked(),
      ),
    );
  }

  bool getIsBookmarked() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (this.news.bookmarkedBy.contains(user.uid)) {
        return true;
      }
    }
    return false;
  }
}
