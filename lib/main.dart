import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final dummySnapshot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController(); //텍스트 입력값을 받기 위한 컨트롤러 함수 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton( //플로팅 액션 버튼 추가
        onPressed: (){  //누르면
          showDialog( //다이얼로그 보여주는 함수
            context: context,
            builder: (BuildContext context) {
              return AlertDialog( //리턴값 확인
                title: Text("Add a baby name"),
                content: TextField(
                  controller : myController,  //컨트롤러 함수를 통해 입력값 받음
                ),
                actions: <Widget>[  //버튼 설정할거다
                  Row(
                    children: <Widget>[
                      FlatButton(
                        child: Text("Add"),
                        onPressed: () {
                          Firestore.instance.collection('baby').add({'name':myController.text,'votes': 0, 'dislike': 0}); //요렇게 하면 데이터베이스에 데이터 추가
                        },
                      ),
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(  //리스트타일 다시 공부하기
            leading: Container( //컨테이너로 싸야 함 안 그럼... 힘듬
              child: IconButton(  //쓰레기통 아이콘버튼 추가
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () => record.reference.delete(), //데이터 지우는 건 이렇게 간단히 해결
              ),
            ),
            title: Text(record.name),
            trailing: SizedBox( //다른 거 집어넣으면 에러 남... 다른 대안 찾아보기(하드코딩 ㄴㄴ)
              width: 100,
              height: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: IconButton(
                            icon: Icon(
                          Icons.thumb_up,
                        ),
                          onPressed: () => record.reference.updateData({"votes": FieldValue.increment(1)}), //좋아요 증가
                        ),
                      ),
                      Container(
                        child: Text(record.votes.toString()),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: IconButton(
                            icon: Icon(
                          Icons.thumb_down,
                        ),
                          onPressed: () => record.reference.updateData({"dislike": FieldValue.increment(1)}), //안 좋아요 증가
                        ),
                      ),
                      Container(
                        child: Text(record.dislike.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
      //trailing: Text(record.votes.toString()),
      //onTap: () => record.reference.updateData({"votes": FieldValue.increment(1)}), //#11 동시에 클릭할 경우 제대로 카운트 못 하는 문제 해결
    );
  }
}

class Record {
  final String name;
  final int votes;
  final int dislike;  //안 좋아요 추가
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        assert(map['dislike'] != null), //안 좋아요 추가
        name = map['name'],
        votes = map['votes'],
        dislike = map['dislike']; //안 좋아요 추가


  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
