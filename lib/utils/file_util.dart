class FileUtil {
  static const List<String> _videoSuffix = ["mp4","flv","f4v","webm","m4v","mov",
  "3gp","3g2","wmv","avi","asf","mpg","mpeg","mpe","ts","div","dv","divx"];

  static bool isVideo(String fileName) {
    var split = fileName.split(".");
    // 文件名中没有.，无法提取出后缀
    if (split.length < 2) {
      return false;
    }

    return _videoSuffix.contains(split[split.length - 1]);
  }

  static String getFileName(String file) {
    var split = file.split(".");
    // 文件名中没有.，无法提取出后缀
    if (split.length < 2) {
      return "";
    }
    return file.substring(0,file.lastIndexOf("."));
  }

}