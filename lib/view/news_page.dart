import 'dart:async';

import 'package:coders_bucket/view/bookmarks.dart';
import 'package:coders_bucket/view/login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coders_bucket/controller/news_controller.dart';
import 'package:coders_bucket/model/news_model.dart';
import 'package:coders_bucket/view/article_page.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NewsScreen extends StatefulWidget {
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsController newsController = Get.put(NewsController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<bool> isArticleBookmarked = [];

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    final articlesCount = newsController.news.value.articles?.length ?? 0;
    isArticleBookmarked = List<bool>.filled(articlesCount, false);
  }

  Future<bool> _isArticleBookmarked(String articleId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    final querySnapshot = await _firestore
        .collection('bookmarks')
        .doc(user.uid)
        .collection('articles')
        .where('articleId', isEqualTo: articleId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _bookmarkArticle(Articles article) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('bookmarks')
          .doc(user.uid)
          .collection('articles')
          .doc(article.source?.id)
          .set({
        'title': article.title,
        'description': article.description,
        'imageUrl': article.urlToImage,
        'content': article.content,
        'publishedAt': article.publishedAt,
        'source': article.source!.name,
      });
      print('Article bookmarked successfully!');
    } catch (e) {
      print('Error bookmarking article: ${e.toString()}');
    }
  }

  void _removeBookmark(String bookmarkId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('bookmarks')
          .doc(user.uid)
          .collection('articles')
          .doc(bookmarkId)
          .delete();
      print('Bookmark removed successfully!');
    } catch (e) {
      print('Error removing bookmark: ${e.toString()}');
    }
  }

  void _logout() async {
    try {
      await _firebaseAuth.signOut();
      Get.offAll(() => LoginPage());
    } catch (e) {
      print('Error during logout: ${e.toString()}');
    }
  }

  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> checkConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      isDeviceConnected = isDeviceConnected;
    });

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && !isAlertSet) {
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('News'),
        backgroundColor: Colors.blueGrey,
        actions: [
          TextButton(
            onPressed: () {
              // Handle Bookmarks button press
              Get.to(() => BookmarkedArticlePage());
            },
            child: Text(
              'Bookmarks',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (newsController.news.value.articles == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final articles = newsController.news.value.articles!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                final articleId = article.source!.id ?? '';

                return GestureDetector(
                  onTap: () {
                    Get.to(ArticleScreen(
                      article: article,
                    ));
                  },
                  child: SizedBox(
                    width: 300.0,
                    height: 110.0,
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        tileColor: Colors.white,
                        leading: article.urlToImage != null
                            ? Container(
                                width: 80.0,
                                height: 80.0,
                                child: Image.network(
                                  article.urlToImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 80.0,
                                height: 80.0,
                                color: Colors.grey,
                              ),
                        title: Text(
                          article.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          article.description ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: FutureBuilder<bool>(
                          future: _isArticleBookmarked(articleId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Icon(Icons.bookmark_outline);
                            } else {
                              final isBookmarked = snapshot.data ?? false;

                              return IconButton(
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color:
                                      isBookmarked ? Colors.red : Colors.green,
                                ),
                                onPressed: () {
                                  if (isBookmarked) {
                                    _removeBookmark(articleId);
                                  } else {
                                    _bookmarkArticle(article);
                                  }
                                  setState(() {
                                    isArticleBookmarked[index] =
                                        !isArticleBookmarked[index];
                                  });
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        elevation: 10,
        onPressed: _logout,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            Text(
              'Log Out',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        mini: false,
      ),

    );
  }

  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('No Connection'),
      content: const Text('Please check your internet connectivity'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected =
            await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );

}
