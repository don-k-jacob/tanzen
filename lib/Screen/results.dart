import 'package:flutter/material.dart';
import 'package:share/share.dart';


List<dynamic> aData = List<dynamic>();
class Results extends StatefulWidget {
  @override
  _ResultsState createState() => _ResultsState();
}
bool monVal = false;
class _ResultsState extends State<Results> {
  List<Widget> _pageData = List<Widget>();
  bool get _fetchingData => _pageData.isEmpty;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xff89f7fe), Color(0xff66a6ff)])),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
           children: <Widget>[
             SizedBox(
               height: 100,
             ),
             ListView.separated(itemBuilder: (BuildContext context, ind){
               AudioFiles item=listTile[ind];
           return ListTile(context,item.icon,item.checkVal,ind);
         }, separatorBuilder: (BuildContext context, int index) => const Divider(),
             itemCount: listTile.length,shrinkWrap: true,),
             SizedBox(
               height: 100,
             ),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: <Widget>[
                 RaisedButton(onPressed: (){
                   Share.share('check out my website https://example.com', subject: 'Look what I made!');
                 },
                 child: Text("Share"),
                 ),
                 RaisedButton(onPressed: (){

                 },
                   child: Text("Save"),
                 )
               ],
             )
           ],
          ),
        ),
      ),
    );
  }

  Container ListTile(BuildContext context,IconData iconData,bool val,int ind) {
    return Container(
           color: Color(0x22ffffff),
           height: 100,
           width: MediaQuery.of(context).size.width-50,
           child: Center(
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: <Widget>[
                 Container(
                   width: MediaQuery.of(context).size.width/2+30,
                   height: 50,
                   color: Colors.white,
                 ),
                 IconButton(icon: Icon(iconData,size: 40,), onPressed: (){

                 }),
                 Checkbox(
                   value: val,
                   onChanged: (bool value) {
                     setState(() {
                       listTile[ind].checkVal=value;
                       val = value;
                     });
                   },
                 ),
               ],
             ),
           ),
         );
  }

}
List<AudioFiles> listTile=[
AudioFiles(icon: Icons.play_arrow,checkVal: false,audio: false),
  AudioFiles(icon: Icons.play_arrow,checkVal: false,audio: false),
  AudioFiles(icon: Icons.play_arrow,checkVal: false,audio: false),
  AudioFiles(icon: Icons.play_arrow,checkVal: false,audio: false),


];
class AudioFiles
{
  final icon;
  bool checkVal;
  final audio;

  AudioFiles({this.icon, this.audio,bool checkVal}) : checkVal = false;


}