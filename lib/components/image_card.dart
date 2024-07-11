import 'package:flutter/material.dart';

class ImageCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final VoidCallback? bookmarkOnTap;
  final bool isBookmark;

  ImageCard(
      {required this.imageUrl,
      required this.title,
      required this.description,
      this.onTap,
      this.bookmarkOnTap,
      required this.isBookmark});

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    padding: EdgeInsets.all(8),
                    child: IconButton(
                      icon: Icon(
                        widget.isBookmark ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: widget.bookmarkOnTap,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title + widget.isBookmark.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.description,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
