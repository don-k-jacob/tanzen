import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:tanzen/Screen/results.dart';

import 'package:path/path.dart' as path;

class AppUtil {

  static Future<String> getFileNameWithExtension(File file) async {
    if (await file.exists()) {
      //To get file name without extension
      //path.basenameWithoutExtension(file.path);

      //return file with file extension
      return path.basename(file.path);
    } else {
      return null;
    }
  }

}

  enum PlayerState { stopped, playing, paused }
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  File localFilePath;

  PlayerState playerState = PlayerState.stopped;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }
  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = Duration(seconds: 0);
            position = Duration(seconds: 0);
          });
        });
  }
  Future _playLocal() async {
    await audioPlayer.play(localFilePath.path,isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }


  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    String fileNameWithExtension="";
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: ()async{
        setState(() async{
          isPlaying ?
          stop():null;
          localFilePath=await FilePicker.getFile(
            type: FileType.custom,
            allowedExtensions: ['mp3','m4a'],
          );
          fileNameWithExtension = await AppUtil.getFileNameWithExtension(localFilePath);
        });

      },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Color(0xff6C63FF),
      ),
      body: Stack(
        children: <Widget>[

          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xff89f7fe), Color(0xff66a6ff)])),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
//                  Image.asset("assets/images/recording.png"),
                  _buildPlayer(),
                  SizedBox(height: 30,),
                  localFilePath != null ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text("${path.basename(localFilePath.path)}",style: TextStyle(color: Colors.white,fontSize: 20),textAlign: TextAlign.center,),
                  ) : Container(),
                  SizedBox(height: 30,),

                  RaisedButton(onPressed: () async {
                    fileNameWithExtension = await AppUtil.getFileNameWithExtension(localFilePath);

                    _positionSubscription.cancel();
                    _audioPlayerStateSubscription.cancel();
                    audioPlayer.stop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Results()),

                    );
                  },
                  color: Color(0xff6C63FF),
                  child: Text("process",),)

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
  Widget playerIcon_(PlayerState status) {
    switch (status) {
      case PlayerState.playing:
        {
          return Icon(Icons.pause_circle_filled);
        }
      case PlayerState.paused:
        {
          return Icon(Icons.play_circle_filled);
        }
      case PlayerState.stopped:
        {
          return Icon(Icons.play_circle_filled);
        }
    }
  }

  Widget _buildPlayer() => Container(
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
//        Row(mainAxisSize: MainAxisSize.min, children: [
//          IconButton(
//            onPressed: isPlaying ? null : () => _playLocal(),
//            iconSize: 64.0,
//            icon: Icon(Icons.play_arrow),
//            color: Color(0xff6C63FF),
//          ),
//          IconButton(
//            onPressed: isPlaying ? () => pause() : null,
//            iconSize: 64.0,
//            icon: Icon(Icons.pause),
//            color: Color(0xff6C63FF),
//          ),
//          IconButton(
//            onPressed: isPlaying || isPaused ? () => stop() : null,
//            iconSize: 64.0,
//            icon: Icon(Icons.stop),
//            color: Color(0xff6C63FF),
//          ),
//        ]),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  height: 250.0,
                  width: 250.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 20,
                    value: position != null && position.inMilliseconds > 0
                        ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
                        (duration?.inMilliseconds?.toDouble() ?? 0.0)
                        : 0.0,
                    valueColor: AlwaysStoppedAnimation(Color(0xff6C63FF)),
                    backgroundColor: Color(0x446C63FF),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child:Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                     ),

                    child: IconButton(

                      onPressed: isPlaying ?()=> pause(): () => _playLocal(),
                      iconSize: 235,
                      icon: playerIcon_(playerState),

                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          Slider(

              value:(duration != null)?position?.inMilliseconds?.toDouble() ?? 0.0:0,
              onChanged: (double value) {
                setState(() {
                  return audioPlayer.seek((value / 1000).roundToDouble());
                });
              },
              min: 0.0,
              max: (duration != null)?duration.inMilliseconds.toDouble():100),

//        if (position != null) _buildMuteButtons(),
//        if (position != null) _buildProgressView()
      ],
    ),
  );

  Column _buildProgressView() => Column(mainAxisSize: MainAxisSize.min, children: [
    Padding(
      padding: EdgeInsets.all(12.0),
      child: CircularProgressIndicator(
        value: position != null && position.inMilliseconds > 0
            ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
            (duration?.inMilliseconds?.toDouble() ?? 0.0)
            : 0.0,
        valueColor: AlwaysStoppedAnimation(Color(0xff6C63FF)),
        backgroundColor: Colors.grey.shade400,
      ),
    ),
    Text(
      position != null
          ? "${positionText ?? ''} / ${durationText ?? ''}"
          : duration != null ? durationText : '',
      style: TextStyle(fontSize: 24.0,color: Colors.white),
    )
  ]);

//  Row _buildMuteButtons() {
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//      children: <Widget>[
//        if (!isMuted)
//          FlatButton.icon(
//            onPressed: () => mute(true),
//            icon: Icon(
//              Icons.headset_off,
//              color: Color(0xff6C63FF),
//            ),
//            label: Text('Mute', style: TextStyle(color: Color(0xff6C63FF))),
//          ),
//        if (isMuted)
//          FlatButton.icon(
//            onPressed: () => mute(false),
//            icon: Icon(Icons.headset, color: Color(0xff6C63FF)),
//            label: Text('Unmute', style: TextStyle(color: Color(0xff6C63FF)),
//          ),),
//      ],
//    );
//  }
}

