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
   