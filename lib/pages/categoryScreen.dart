import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'courseScreen.dart';

class CategoryScreen extends StatefulWidget {
  final DocumentReference _documentReference;
  CategoryScreen(this._documentReference);
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Firestore dbRef = Firestore.instance;
  List<String> tempRef;
  bool loading = true;
  Map<String, bool> checkValues = Map();

  @override
  initState(){
    tempRef = List();
    getCheckValues().then((nothing){
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  Future<void> addUserCategory(DocumentReference documentReference) async{
    setState(() {
      loading = true;
    });
    await widget._documentReference.collection("Categories").getDocuments().then((value1) async{
      if(value1.documents.length > 0){
        value1.documents.forEach((element) { 
          tempRef.add(element.data["category"].documentID);
        });
        if(tempRef.contains(documentReference.documentID)){
          print("Document Already Exits");
        } else{
          await widget._documentReference.collection("Categories").add({
            'category' : documentReference,
            'length' : await documentReference.collection("Courses").getDocuments().then((value) => value.documents.length),
            'title' : await documentReference.get().then((value) => value["title"])
          });
        }
      }
      else{
        await widget._documentReference.collection("Categories").add({
          'category' : documentReference,
          'length' : await documentReference.collection("Courses").getDocuments().then((value) => value.documents.length),
          'title' : await documentReference.get().then((value) => value["title"])
        });
      }
    });
  }

  Future<void> getCheckValues() async{
    await widget._documentReference.collection("Categories").getDocuments().then((value) async{
      if(value.documents.length > 0){
        value.documents.forEach((element) { 
          tempRef.add(element.data["category"].documentID);
        });
        await dbRef.collection("Categories").getDocuments().then((docs){
          docs.documents.forEach((doc) { 
            checkValues[doc.documentID] = tempRef.contains(doc.documentID);
          });
        });
      } 
      else{
        await dbRef.collection("Categories").getDocuments().then((docs){
          docs.documents.forEach((doc) { 
            checkValues[doc.documentID] = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading ? Container(
        child: Center(
          child: CircularProgressIndicator(),
        )
      ) : Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: FutureBuilder(
          future: dbRef.collection("Categories").getDocuments(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasData){
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator()
                  );
                  break;
                default:
                  List<DocumentSnapshot> docSnap = snapshot.data.documents;
                  return Column(
                    children: <Widget>[
                      SizedBox(height:50),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select What to learn",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline1.color,
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height - 130,
                        child: GridView.builder(
                          itemCount: docSnap.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2
                          ), 
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.topRight,
                                    child: Checkbox(
                                      key: Key(docSnap[index].documentID),
                                      activeColor: Color(0xFF31A0FF),
                                      checkColor: Colors.white,
                                      value: checkValues[docSnap[index].documentID], 
                                      onChanged: (value){
                                        setState(() {
                                          checkValues[docSnap[index].documentID] = value;
                                        });
                                      }
                                    )
                                  ),
                                  FittedBox(
                                    child: Container(
                                      height: 113,
                                      width: MediaQuery.of(context).size.width - 250,
                                      padding: EdgeInsets.only(left:10,right:10, bottom: 10),
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        docSnap[index]["title"],
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.4
                                        ),
                                      )
                                    ),
                                  )
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF02B2FE),
                                    Colors.white.withOpacity(0.3)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                                  image: NetworkImage(
                                    docSnap[index]["coverImageUrl"]
                                  )
                                ),
                                borderRadius: BorderRadius.circular(5)
                              ),
                            );
                          }
                        )
                      ),
                    ],
                  );
              }
            }
            else if(snapshot.hasError){
              return Center(
                child: Text("Oops Error Occured")
              );
            }
            else{
              return Center(
                child: CircularProgressIndicator()
              );
            }
          }
        )
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          color: Theme.of(context).accentColor,
          onPressed: (){
            checkValues.forEach((key, value) async{ 
              if(checkValues[key] == true){
                addUserCategory(dbRef.collection("Categories").document(key)).then((value){ 
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => CourseScreen(widget._documentReference)));
                });
              }
            });
          },
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
          )
        )
        
      ),
    );
  }
}