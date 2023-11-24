import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_innovainfosys/WebVew/back_pressed.dart';
import 'package:pos_innovainfosys/WebVew/no_internet_connection.dart';


class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> with TickerProviderStateMixin {
final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  PullToRefreshController? _refreshController;
late AnimationController _animationController;

  bool _isLoading = false, _isVisible = false, _isOffline = false;

  // 0 - Everything is ok, 1 - http or other error fixed
  int _errorCode = 0;
  final BackPressed _backPressed = BackPressed();
  //
  // InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
  //   crossPlatform: InAppWebViewOptions(
  //     javaScriptEnabled: true,
  //     useShouldOverrideUrlLoading: true,
  //     useOnDownloadStart: true,
  //     allowFileAccessFromFileURLs: true,
  //     mediaPlaybackRequiresUserGesture: false,
  //   ),
  //   android: AndroidInAppWebViewOptions(
  //     initialScale: 100,
  //     allowFileAccess: true,
  //     useShouldInterceptRequest: true,
  //     useHybridComposition: true,
  //   ),
  //   ios: IOSInAppWebViewOptions(
  //     allowsInlineMediaPlayback: true,
  //   ),
  // );


  Future<void> checkError() async {
    //Hide CircularProgressIndicator
    _isLoading = false;

    //Check Network Status
    ConnectivityResult result = await Connectivity().checkConnectivity();

    //if Online: hide offline page and show web page
    if (result != ConnectivityResult.none) {
      if (_isOffline == true) {
        _isVisible = false; //Hide Offline Page
        _isOffline = false; //set Page type to error
      }
    }

    //If Offline: hide web page show offline page
    else {
      _errorCode = 0;
      _isOffline = true; //Set Page type to offline
      _isVisible = true; //Show offline page
    }

    // If error is fixed: hide error page and show web page
    if (_errorCode == 1) _isVisible = false;
    setState(() {});
  }



  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat();
    _refreshController = PullToRefreshController(
      onRefresh: () => _webViewController!.reload(),
      options: PullToRefreshOptions(
          color: Colors.white, backgroundColor: Colors.black87),
    );
  }
@override
void dispose() {
    _animationController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InAppWebView(
                  key:webViewKey,
                  onWebViewCreated: (controller) =>
                  _webViewController = controller,
                  // initialOptions: options,
              initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      supportZoom: false,
                    )),
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(
                          "https://pos.innovainfosys.com/")), // For http error: change to wrong url : https://google.com/404/
                  pullToRefreshController: _refreshController,
                   onDownloadStart: (controller, url) async {
                      // downloading a file in a webview application
                      print("onDownloadStart $url");
                      await FlutterDownloader.enqueue(
                        url: url.toString(), // url to download
                        savedDir: (await getExternalStorageDirectory())!.path,
                        // the directory to store the download
                        fileName: 'downloads',
                        headers: {},
                        showNotification: true,
                        openFileFromNotification: true,
                      );
                    },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true; //Show CircularProgressIndicator
                    });
                  },
                     androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                  onLoadStop: (controller, url) {
                    _refreshController!.endRefreshing();
                    checkError(); //Check Error type: offline or other error
                  },
                  onLoadError: (controller, url, code, message) {
                    // Show
                    _errorCode = code;
                    _isVisible = true;
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    _errorCode = statusCode;
                    _isVisible = true;
                  },
                ),
                //Error Page
                Visibility(
                  visible: _isVisible,
                  child: NoInternetScreen(
                      onTap: () {
                        _webViewController!.reload();
                        if (_errorCode != 0) {
                          _errorCode = 1;
                        }
                      }),
                ),
                //CircularProgressIndicator
                Visibility(
                  visible: _isLoading,
                  child:CircularProgressIndicator.adaptive(
                    valueColor: _animationController.drive(
                      ColorTween(
                          begin:  Color(0xFF448AFF),
                          end:  Color(0xFFF44336))
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          //If website can go back page
          if (await _webViewController!.canGoBack()) {
            await _webViewController!.goBack();
            return false;
          } else {
            //Double pressed to exit app
            return _backPressed.exit(context);
          }
        });
  }
}