import 'package:coders_bucket/model/news_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';



class NewsController extends GetxController {
  final String apiUrl =
      'https://newsapi.org/v2/everything?q=apple&from=2023-07-14&to=2023-07-14&sortBy=popularity&apiKey=d77d8ca990794a4a9a582f8cda62418e';

  final news = NewsModel().obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await Dio().get(apiUrl);
      final jsonData = response.data;
      news.value = NewsModel.fromJson(jsonData);
    } catch (error) {
      print('Error: $error');
    } finally {
      isLoading.value = false;
    }
  }
}
