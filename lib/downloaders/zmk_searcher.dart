import '../bean/subtitle_url.dart';
import 'interface_searcher.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class ZMKSearcher implements ISearcher{
  @override
  Future<List<SubtitleUrl>> search(String fileName) async {
    print("zmk search start...");
    Dio dio = new Dio();
    // 查询
    var url = "https://so.zimuku.org/search?q=$fileName";
    print("search: $url");
    var response = await dio.post(url);

    // 解析出字幕页url
    var document = parse(response.data);
    var elementsByClassName = document.body?.getElementsByClassName("tt clearfix");
    var subtitlePageUrl = elementsByClassName?.first.getElementsByTagName("a").first.attributes["href"];

    if (subtitlePageUrl?.isEmpty == true) {
      print("没有搜索到相关电影。");
      return [];
    }
    // 请求字幕页
    url = "https://zimuku.org$subtitlePageUrl";
    print("request: $url");
    response = await dio.post(url);
    //print(response.data);

    // 解析字幕列表的信息
    document = parse(response.data);
    var trTag = document.getElementById("subtb")?.getElementsByTagName("tbody").first.getElementsByTagName("tr");
    if (trTag == null) {
      print("没有搜索到相关字幕。");
      return [];
    }

    List<_ZMKSubtitle> zmkSubtitleList = [];
    // 解析出每个字幕的信息
    for (var tr in trTag) {
      var attribute = tr.getElementsByTagName("a");
      var idUrl = attribute.first.attributes["href"];
      var title = attribute.first.attributes["title"];

      var id = parseIdFromUrl(idUrl);

      if(id != null && title != null) {
        var zmkSubtitle = _ZMKSubtitle(id,title);
        zmkSubtitleList.add(zmkSubtitle);
      }

    }

    if (zmkSubtitleList.isEmpty) {
      print("没有查询到有效字幕。");
      return [];
    }

    // 通过id获取下载地址
    for (var sub in zmkSubtitleList) {
      url = "https://zimuku.org/dld/${sub.id}.html";
      response = await dio.post(url);
      document = parse(response.data);
      var aTags = document.getElementsByClassName("down clearfix").first.getElementsByTagName("a");
      for (var aTag in aTags) {

        var downloadUrl = aTag.attributes["href"];
        if (downloadUrl != null) {
          downloadUrl = "https://zimuku.org$downloadUrl";
          sub.urls.add(downloadUrl);
          sub.referer = url;
        }
      }
    }

    // 组装为SubtitleUrl
    List<SubtitleUrl> results = [];
    for (var sub in zmkSubtitleList) {
      results.add(SubtitleUrl(sub.title,sub.urls,headers: {'Referer': sub.referer}));
    }


    return results;
  }

  /// 从idUrl中提取出id
  String? parseIdFromUrl(String? idUrl) {
    if (idUrl == null) {
      return null;
    }

    var start = idUrl.lastIndexOf("/");
    var end = idUrl.indexOf(".html");


    return idUrl.substring(start + 1,end);
  }



}
class _ZMKSubtitle {
  String id;
  String title;
  String rate;
  String referer = "";
  List<String> urls = [];
  List<String>? languages;

  _ZMKSubtitle(this.id,this.title,{this.rate = "",this.languages});

  @override
  String toString() {

    return "ZMKSubtitle$hashCode id: $id,title: $title  urls:$urls";
  }

}