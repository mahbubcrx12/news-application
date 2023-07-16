import 'package:coders_bucket/view/news_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookmarkedArticle extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final String publishedAt;
  final String source;

  const BookmarkedArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    required this.publishedAt,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Bookmarked Article'),
      ),
      body: Column(
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl,
              // height: 200,
              // width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Content:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(content),
                SizedBox(height: 16),
                Text(
                  'Published At:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(publishedAt),
                SizedBox(height: 16),
                Text(
                  'Source:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(source),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        elevation: 10,
        onPressed: (){
          Get.to(()=>NewsScreen());
        },
        child: Icon(Icons.home),

        materialTapTargetSize: MaterialTapTargetSize.padded,
        mini: false,
      ),
    );
  }
}
