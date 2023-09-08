import 'dart:async';
import 'dart:io';


import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helpus/util/database.dart';
import 'package:helpus/util/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }


//mp3 url 주소
const mUrls = ['http://helpus.itforone.co.kr/data/genesis_01_01.mp3',
               'http://helpus.itforone.co.kr/data/genesis_01_02.mp3',
               'http://helpus.itforone.co.kr/data/genesis_01_03.mp3',
               'http://helpus.itforone.co.kr/data/genesis_01_04.mp3',
               'http://helpus.itforone.co.kr/data/genesis_01_05.mp3',
               'http://helpus.itforone.co.kr/data/genesis_01_06.mp3'
              ];
//mp3 제목
const mTitles = ['1일차 - 01창세기_01장.mp3',
                 '1일차 - 01창세기_02장.mp3',
                 '1일차 - 01창세기_03장.mp3',
                 '2일차 - 01창세기_04장.mp3',
                 '2일차 - 01창세기_05장.mp3',
                 '2일차 - 01창세기_06장.mp3'
                ];
void main() => runApp(
  MaterialApp(
    home: MyApp(),
  )
);

class MyApp extends StatelessWidget {
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
        primaryColor: Colors.white,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  AppLifecycleState _lastLifecycleState; //앱상태 변수

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  final key = GlobalKey<ScaffoldState>();


  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';
  bool _isDownload = false;

  var speeds = [1.0,1.2,1.5,2.0,3.0];
  var speedsTxt = ['1.0','1.2','1.5','2.0','3.0'];
  int speed=0;
  String speedTxt='1.0';
  //플레이관련된 변수
  int pDay=0;//날짜관련
  int pList=0;//해당리스트
  var dayTitles = ['1일차','2일차','3일차','4일차','5일차','6일차','7일차','8일차','9일차','10일차','11일차','12일차','13일차','14일차','15일차',
                   '16일차','17일차','18일차','19일차','20일차','21일차','22일차','23일차','24일차','25일차','26일차','27일차','28일차','29일차','30일차'];//날짜별로 배열
  var listCounts = [36,38,40,25,34,33,32,35,26,33,29,46,43,77,95,51,44,40,34,37,42,53,28,24,23,26,32,35,49,43];//날짜별로 파일 갯수 배열
  int mIdx=0;
  String dir='';
  bool isStorage=false;
  int downloadSu=0;
  final MAXDOWNLOADSU=1183;
  List _data = []; // 목록 데이터를 가지고 옴
  var weekday=DateTime.now().weekday;
  final weekdays=['월','화','수','목','금','토','일'];
  FlutterLocalNoti