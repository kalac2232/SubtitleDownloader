import 'dart:io';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:subtitle_downloader/utils/file_util.dart';
import 'package:subtitle_downloader/bean/movie_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'downloaders/downloader_presenter.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    window_size.setWindowFrame(Rect.fromLTRB(20,20,800,600));
  }
  if (Platform.isMacOS) {
    window_size.setWindowFrame(Rect.fromLTRB(20,20,400,300));
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      window_size.setWindowTitle(_packageInfo.appName +'  v' + _packageInfo.version);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          children: [
            Positioned(child: ExampleDragTarget(),),
            //Positioned(child: Text(_packageInfo.version,style: TextStyle(fontSize: 12,color: Colors.black54),),right: 10,bottom: 3,)
          ],
        ),
      ),
    );
  }
}

class ExampleDragTarget extends StatefulWidget {

  ExampleDragTarget({Key? key}) : super(key: key);

  @override
  _ExampleDragTargetState createState() => _ExampleDragTargetState();
}

class _ExampleDragTargetState extends State<ExampleDragTarget> {
  bool _dragging = false;
  bool _loading = false;
  final List<MovieFile> _list = [];


  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          var iterator = detail.files.iterator;
          while (iterator.moveNext()) {
            _list.add(MovieFile(name: iterator.current.name,path: iterator.current.path));
          }
          if( _list.isNotEmpty) {
            _loading = true;
            startSearchSubTitle(_list);
          }
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        width: 240,
        height: 180,
        //color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
        decoration: BoxDecoration(
          border: RDottedLineBorder.all(
            width: 2,
            color: _dragging ? Colors.blue : Colors.black26,
          ), // 边色与边宽度
          //color: Color(0xFF9E9E9E), // 底色
          borderRadius: BorderRadius.circular((20.0)), // 圆角度
        ),
        child: Center(
          child: Text(!_dragging? "Drop here":"OK",
            style: TextStyle(
                color: _dragging ? Colors.blue : Colors.black54,
                fontSize: 18
            ),
          ),
        ),
      ),
    );
  }

  void startSearchSubTitle(List<MovieFile> list) {

    var downloaderPresenter = DownloaderPresenter();

    for (var file in list) {
      if (!FileUtil.isVideo(file.name)) {
        continue;
      }

      downloaderPresenter.start(fileName: FileUtil.getFileName(file.name),saveDir: File(file.path).parent);
    }

  }
}
