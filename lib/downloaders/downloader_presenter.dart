import 'dart:io';

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

      var bool = await saveDir.exists();
      if (bool) {
        await saveDir.create(recursive: true);
      }

    }
  }

  void initDownloader() {
    downloaderList.add(ZMKSearcher());
  }
}