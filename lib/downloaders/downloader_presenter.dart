import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:subtitle_downloader/utils/file_util.dart';

import 'interface_searcher.dart';
import 'zmk_searcher.dart';

class DownloaderPresenter {

  List<ISearcher> downloaderList = [];

  DownloaderPresenter() {
    initDownloader();
  }
  Dio dio = new Dio();
  Future<void> start({required String searchKey,required Directory saveDir}) async {
    //dio.interceptors.add(LogInterceptor());
    int successCount = 0;
    for(var d in downloaderList) {
      var searchResult = await d.search(searchKey);
      // 没有查询到字幕
      if (searchResult.isEmpty) {
        continue;
      }

      print("开始下载${searchResult.length}个字幕");
      List<Future> queue = [];
      for (var sub in searchResult) {
        var future = Future(() async {
          String filePath = FileUtil.createTempSubtitleFile(saveDir);
          print("创建$filePath文件");
          print("开始下载${sub.name}");

          for (var url in sub.downloadUrls) {
            var success = await downloadSubtitle(url,sub.headers, filePath);
            if (success) {
              successCount++;
              break;
            }
          }
        });
        queue.add(future);
      }
      // 同时开始下载任务
      await Future.wait(queue);

    }
    print("$searchKey相关字幕下载完成，共下载$successCount个字幕");
  }

  void initDownloader() {
    downloaderList.add(ZMKSearcher());
  }


  Future<bool> downloadSubtitle(String downloadUrl,Map<String,String>? headers,String savePath) async {

    var response = await dio.download(downloadUrl, savePath,options: Options(headers: headers,followRedirects: true));

    if (response.statusCode == 200) {
      var disposition = response.headers["content-disposition"];
      if (disposition != null) {
        var fileName = getFileName(disposition.first);
        // 重命名文件
        FileUtil.renameFile(File(savePath), fileName!);
      } else {
        // 可能触发了下载限制，删除临时文件
        File(savePath).delete();
        return false;
      }
    }

    return response.statusCode == 200;
  }


  /// 从content-disposition中取出文件名
  String? getFileName(String? disposition) {
    if (disposition == null) {
      return null;
    }

    var index = disposition.indexOf("filename=\"");

    return Uri.decodeComponent(disposition.substring(index + 10,disposition.length -1));

  }
}