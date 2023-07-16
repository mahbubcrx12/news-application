import 'package:coders_bucket/view/news_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/news_model.dart';
import 'package:intl/intl.dart';


class ArticleScreen extends StatelessWidget {
  final Articles? article;

  const ArticleScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article?.urlToImage != null)
              Image.network(
                article!.urlToImage!,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article?.title ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Author: ${article?.author ?? 'Unknown'}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(DateFormat('MMM dd, yyyy HH:mm')
                  .format(DateTime.parse('${article!.publishedAt ?? ''}'))),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article?.description ?? '',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article?.content ?? '',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Source: ${article?.source!.name}' ?? '',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          Get.to(()=>NewsScreen());
        },
        child: Icon(Icons.home),
      ),
    );
  }
}
