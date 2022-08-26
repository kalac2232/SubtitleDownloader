import 'dart:io';

import 'package:dio/dio.dart';

import 'interface_searcher.dart';
import 'zmk_searcher.dart';

class DownloaderPresenter {

  List<ISearcher> downloaderList = [];

  DownloaderPresenter() {
    initDownloader();
  }

  Future<void> start({required String fileName,required Directory saveDir}) async {
    for(var d in downloaderList) {
      var searchResult = await d.search(fileName);
      // 没有查询到字幕
      if (searchResult.isEmpty) {
        continue;
      }

      // var bool = await saveDir.exists();
      // if (bool) {
      //   await saveDir.create(recursive: true);
      // }

      print("开始下载${searchResult.length}个字幕");

      for (var sub in searchResult) {
        String filePath = createSubtitleFile(saveDir,sub.name);
        print("创建$filePath文件");
        print("开始下载${sub.name}");
        downloadSubtitle(sub.downloadUrls.first,sub.headers, filePath);
      }

    }
  }

  void initDownloader() {
    downloaderList.add(ZMKSearcher());
  }

  Dio dio = new Dio();
  Future<bool> downloadSubtitle(String downloadUrl,Map<String,String>? headers,String savePath) async {


    var response = await dio.download(downloadUrl, savePath,options: Options(headers: headers));
    print(response.data);

    return false;
  }

  String createSubtitleFile(Directory saveDir, String name) {
    var file = File(saveDir.path+"/"+name);
    file.create(recursive: true);
    return file.path;
  }
}