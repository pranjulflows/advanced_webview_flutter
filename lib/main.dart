import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  WebViewController webViewController = WebViewController();

  @override
  void initState() {
    webViewSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SizedBox(

        child: WebViewWidget(controller: webViewController),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void webViewSettings() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..loadRequest(Uri.parse("https://api.haibooks.com/assets/index.html"))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            // log('Page finished LOAD: $metaJson');
            Future.delayed(Duration(seconds: 1), () {
              webViewController
                  .runJavaScript("var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=0.4'); document.getElementsByTagName('head')[0].appendChild(meta);");
              //
              // webViewController
              //     .runJavaScript('repaintTemplate(''#3f3a49'');');
              // Future.delayed(Duration(seconds: 1),(){
              webViewController
                  .runJavaScriptReturningResult(
                      'window.loadTemplate(\'Template3\');')
                  .then((value) {
                Future.delayed(const Duration(microseconds: 200), () {
                  webViewController.runJavaScript(
                      'setData( \'$metaJson\' ,  \'$imgBase64\' );');
                  webViewController.runJavaScriptReturningResult(
                      'window.setFooter(\'TETdfsdfsdfsdfsdfsfET\');');
                  webViewController.runJavaScriptReturningResult(
                      'window.setAdditionalText(\'Additional sdfsdfsdfsdfsdfsdfsdfsdfsdf\');');
                  webViewController.runJavaScriptReturningResult(
                      'window.repaintTemplate(\'#9360f7\');');
                });
              });

              //
              // });
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
    Page resource error:
   code: ${error.errorCode}
   description: ${error.description}
   errorType: ${error.errorType}
   isForMainFrame: ${error.isForMainFrame}
        ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith('https://api.haibooks.com/assets/index.html')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.navigate;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    // webViewController
    //     .loadRequest(Uri.parse('https://api.haibooks.com/assets/index.html'));
    // webViewController.loadRequest(Uri.parse('https://www.google.com'));
    webViewController = controller;
    // notifyUI();
  }

  String metaJson =
      '{"data":{"emailAddress":"deepakraj@email.com","companyName":"Mohali","additionalText":"This document has been generated for Src in hAibooks","footer":"© Src gfhk;jg dgklhj lghj lkhjkl;gjhklgjhklgjhkl gkhj kgjhk gkhj kgh kgjhk gjhk gh","colorCode":"0000ff","vatNo":"","companyAddress":"Sector 74, mohali, india, 3333, United Kingdom, ","currentTemplateId":5,"templates":[{"id":"3","templateName":"Template 3","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-3.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-3.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-3.png","templateCode":"Template3"},{"id":"4","templateName":"Template 4","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-4.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-4.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-4.png","templateCode":"Template4"},{"id":"5","templateName":"Template 5","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-5.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-5.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-5.png","templateCode":"Template5"},{"id":"6","templateName":"Template 6","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-6.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-6.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-6.png","templateCode":"Template6"},{"id":"7","templateName":"Template 7","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-7.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-7.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-7.png","templateCode":"Template7"},{"id":"8","templateName":"Template 8","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-8.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-8.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-8.png","templateCode":"Template8"},{"id":"9","templateName":"Template 9","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-9.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-9.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-9.png","templateCode":"Template9"},{"id":"10","templateName":"Template 10","mediumSizeImgName":"https://haibooks.com/assets/img/invoice-templates/medium-invoice-pdf-template-10.png","fullSizeImgName":"https://haibooks.com/assets/img/invoice-templates/full-invoice-pdf-template-10.png","smallImgName":"https://haibooks.com/assets/img/invoice-templates/small-invoice-pdf-template-10.png","templateCode":"Template10"}]}}';
  String imgBase64 =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAI8AAACYCAYAAADdsLqwAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF+mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDUgNzkuMTYzNDk5LCAyMDE4LzA4LzEzLTE2OjQwOjIyICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo5ODliNWQyMy1jZTYyLWY1NDUtOWJmMS02ZTZjMjczYzNmODQiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NEU3MTAyQjY4MDYwMTFFOTk4RUJBODhCQjQ3QzMzREMiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6YzU0MmFmM2YtMThiOS0xMzQ4LTlkYWEtMjM0Y2VmNjVlYTk0IiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE5IChXaW5kb3dzKSIg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';

  notifyUI() {
    if (mounted) setState(() {});
  }
}
