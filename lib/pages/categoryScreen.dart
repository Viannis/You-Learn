import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Map> checkValue;

  @override
  initState(){
    tempRef = List();
    checkValue = List();
    getCategories().then((nothing){
      print(nothing);
      setState(() {
        checkValue = nothing;
        loading = false;
      });
    });
    super.initState();
  }

  Future<List<Map>> getCategories() async{
    List<Map> temp = List();
    await widget._documentReference.collection("Categories").getDocuments().then((userCat) async{
      if(userCat.documents.length > 0){
        userCat.documents.forEach((element) { 
          tempRef.add(element.data["category"].documentID);
        });
        await dbRef.collection("Categories").getDocuments().then((docs) async{
          for(var i = 0; i < docs.documents.length; i++){
            temp.add({
              "docId" : docs.documents[i].documentID,
              "selected" : tempRef.contains(docs.documents[i].documentID),
              "title" : docs.documents[i].data["title"],
              "image" : docs.documents[i].data["coverImageUrl"],
              "reference" : docs.documents[i].reference,
              "length" : await docs.documents[i].reference.collection("Courses").getDocuments().then((value) => value.documents.length)
            });
          }
        });
      }
      else{
        await dbRef.collection("Categories").getDocuments().then((docs) async{
          for(var i = 0; i < docs.documents.length; i++){
            temp.add({
              "docId" : docs.documents[i].documentID,
              "selected" : false,
              "title" : docs.documents[i].data["title"],
              "image" : docs.documents[i].data["coverImageUrl"],
              "reference" : docs.documents[i].reference,
              "length" : await docs.documents[i].reference.collection("Courses").getDocuments().then((value) => value.documents.length)
            });
          }
        });
      }
    });
    return temp;
  }

  Future<void> addCategories(List<Map> localCategories) async{
    final CollectionReference categoryRef = widget._documentReference.collection("Categories");
    await categoryRef.getDocuments().then((value) async{
      if(value.documents.length > 0){
        await categoryRef.getDocuments().then((value){
          value.documents.forEach((element) async{ 
            await element.reference.delete();
          });
        });
        localCategories.forEach((element) async{ 
          if(element["selected"]){
            await categoryRef.add({
              'category' : element["reference"],
              "length" : element["length"],
              "title" : element["title"]
            });
          }
        });
      }
      else{
        localCategories.forEach((element) async{ 
          if(element["selected"]){
            await categoryRef.add({
              'category' : element["reference"],
              "length" : element["length"],
              "title" : element["title"]
            });
          }
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
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
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
              child: checkValue.length > 0 ? GridView.builder(
                itemCount: checkValue.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2
                ), 
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: Checkbox(
                            key: Key(checkValue[index]["docId"]),
                            activeColor: Color(0xFF31A0FF),
                            checkColor: Colors.white,
                            value: checkValue[index]["selected"],
                            onChanged: (value){
                              setState(() {
                                checkValue[index]["selected"] = value;
                              });
                            },
                          )
                        ),
                        FittedBox(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 250,
                            padding: EdgeInsets.only(left:10,right:10, bottom: 10),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              checkValue[index]["title"],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.4
                              ),
                            )
                          )
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
                          checkValue[index]["image"]
                        )
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                  );
                }
              ) : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(),
                      Image.asset(
                        './assets/images/Error.png',
                        width: MediaQuery.of(context).size.width * 0.6
                      ),
                      SizedBox(),
                      Text(
                        "Oops!",
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Some error occurred, Check your Internet and try again later',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          color: Theme.of(context).primaryColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(),
                    ],
              )
            ),
          ],
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
            addCategories(checkValue).then((value) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => CourseScreen(widget._documentReference)));
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