import '../bean/subtitle_url.dart';
import 'interface_searcher.dart';
import 'package:dio/dio.dart';

class ZMKSearcher implements ISearcher{
  @override
  Future<List<SubtitleUrl>> search(String fileName) async {
    print("zmk search start...");
    Dio dio = new Dio();
    var url = "https://so.zimuku.org/search?q=$fileName";
    print("search: $url");
    var response = await dio.post(url);

    print(response.data);

    return [];
  }


}