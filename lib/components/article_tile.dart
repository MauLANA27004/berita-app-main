import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:timeago/timeago.dart' as timeago;
import 'package:berita_app/models/news.dart';

class ArticleTile extends StatefulWidget {
  final NewsModel item;
  final VoidCallback? onTap;
  final String item_id;

  const ArticleTile(
      {Key? key, required this.item, this.onTap, required this.item_id})
      : super(key: key);

  @override
  _ArticleTileState createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {

  @override
  void initState() {
    super.initState();
    // checkBookmarkStatus();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 136,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.item.thumbnail),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.item.author} · ${timeago.format(widget.item.created_at.toDate())}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      IconButton(
                        icon: Builder(
                          builder: (context) {
                            if (FirebaseAuth.instance.currentUser != null) {
                              if (widget.item.bookmarkedBy.contains(
                                  FirebaseAuth.instance.currentUser!.uid)) {
                                return Icon(Icons.bookmark);
                              }
                              return Icon(Icons.bookmark_border);
                            }
                            return Icon(Icons.bookmark_border);
                          },
                        ),
                        onPressed: () {
                          toggleBookmark();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  void toggleBookmark() async {
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
          .doc(widget.item_id)
          .collection('bookmarks');

      if (!widget.item.bookmarkedBy.contains(user.uid)) {
        // Add bookmark and update 'bookmarkedBy' field
        await bookmarksRef.doc(user.uid).set({
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update 'bookmarkedBy' in main news document
        await FirebaseFirestore.instance
            .collection('news')
            .doc(widget.item_id)
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
            .doc(widget.item_id)
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
