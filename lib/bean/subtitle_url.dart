class SubtitleUrl {
  String name;
  List<String> downloadUrls;
  Map<String,String>? headers;

  SubtitleUrl(this.name,this.downloadUrls,{this.headers});

  @override
  String toString() {
    return "name: $name urls:$downloadUrls";
  }
}