import '../bean/subtitle_url.dart';

abstract class ISearcher{

  /// 搜索目标字幕的下载地址
  Future<List<SubtitleUrl>> search(String fileName);

}