import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youlearn/pages/courseContentScreen.dart';

class ProfileScreen extends StatefulWidget {
  final DocumentReference documentReference;
  ProfileScreen(this.documentReference);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  bool myCoursesSelected = true;
  bool completedSelected = false;
  int completed = 0;
  bool loading = true;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    getCompletedCount().then((value) {
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  void dispose(){
    controller.dispose();
    super.dispose();
  }

  Future<void> getCompletedCount() async {
    await widget.documentReference.collection("Enrolled").getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.data["completed"]) {
          setState(() {
            completed += 1;
          });
        }
      });
    });
  }

  Future<String> getUrl(Uint8List imageFile) async {
    final String tempUid = widget.documentReference.documentID;
    final StorageReference sRef = storageReference.child("$tempUid/profileImage");
    final StorageUploadTask uploadTask = sRef.putData(imageFile);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    return await downloadUrl.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.textTheme.headline1.color,
            letterSpacing: 0.8
          )
        ),
      ),
      body: loading ? Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator()
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Loading...",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ],
                )
              )
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50),
                    StreamBuilder(
                      stream: widget.documentReference.snapshots(),
                      builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator()
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Loading...",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ],
                                  )
                                )
                              );
                              break;
                            case ConnectionState.active:
                              return Column(
                                children: <Widget>[
                                  Center(
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(
                                              color: Theme.of(context).accentColor,
                                              width: 3
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: Image.network(
                                              snapshot.data["imageUrl"],
                                              fit: BoxFit.cover,
                                              loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null ? 
                                                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                            )
                                          )
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5)
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "Image",
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.add_circle,
                                                          color: Theme.of(context).accentColor,
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.of(context).pop();
                                                          try{
                                                            ImagePicker().getImage(source: ImageSource.gallery).then((value) async{
                                                              value.readAsBytes().then((value1){
                                                                getUrl(value1).then((value2) async{
                                                                  widget.documentReference.updateData({
                                                                    'imageUrl' : value2
                                                                  });
                                                                });
                                                              });
                                                            });
                                                          } catch(e){
                                                            print(e);
                                                          }
                                                          
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                )
                                              );
                                            },
                                            child: Container(
                                              width: 23,
                                              height: 23,
                                              decoration: BoxDecoration( 
                                                borderRadius: BorderRadius.circular(50),
                                                color: Theme.of(context).accentColor
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.photo_camera,
                                                  size: 12,
                                                  color: Colors.white
                                                )
                                              ),
                                            ),
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      SizedBox(width: 48),
                                      Container(
                                        width: 150,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            snapshot.data["name"].toString().length > 15 ? snapshot.data["name"].toString().substring(0, 12) + "..."
                                              : snapshot.data["name"],
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22,
                                              letterSpacing: 1
                                            )
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 16),
                                        onPressed: () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5)
                                              ),
                                              title: TextFormField(
                                                autofocus: true,
                                                maxLength: 15,
                                                maxLengthEnforced: true,
                                                controller: controller,
                                                decoration: InputDecoration(
                                                  labelText: 'Name',
                                                  labelStyle: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500
                                                  )
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  letterSpacing: 0.2,
                                                  fontWeight: FontWeight.w500
                                                ),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: (){
                                                    controller.clear();
                                                    Navigator.of(context).pop();
                                                  }, 
                                                  child: Text(
                                                    "Cancel",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      letterSpacing: 1,
                                                      fontWeight: FontWeight.w500
                                                    ),
                                                  )
                                                ),
                                                FlatButton(
                                                  onPressed: () async{
                                                    String tempName = controller.text;
                                                    controller.clear();
                                                    Navigator.of(context).pop();
                                                    if(tempName.length > 1){
                                                      widget.documentReference.updateData({
                                                        'name' : tempName
                                                      });
                                                    }
                                                  }, 
                                                  child: Text(
                                                    "Update",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      letterSpacing: 1,
                                                      fontWeight: FontWeight.w500
                                                    ),
                                                  )
                                                )
                                              ],
                                            )
                                          );
                                        }
                                      )
                                    ]
                                  ),
                                  Center(
                                    child: Text(snapshot.data["email"],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor,
                                        letterSpacing: 0.3
                                      )
                                    )
                                  ),
                                ],
                              );
                            default:
                              return Center(child: CircularProgressIndicator());
                          }
                        } else {
                          return Column(
                            children: <Widget>[
                              Center(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Theme.of(context).accentColor,
                                          width: 3
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          "https://lh3.googleusercontent.com/proxy/l9TsrUg0X7nwzOLJH-SCkpsK3of47HdGxrPgkF2nil85UdcocPSwIFZkGWJPmwsWmp3SgTwAedDIgmUFPfI8ky5j4BRW6-QwBbqT4UHdkGF46l5iinU",
                                          fit: BoxFit.cover
                                        )
                                      )
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 0,
                                      child: GestureDetector(
                                        child: Container(
                                          width: 23,
                                          height: 23,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            color: Theme.of(context).accentColor
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.mode_edit,
                                              size: 12,
                                              color: Colors.white
                                            )
                                          ),
                                        ),
                                      )
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(width: 48),
                                  Container(
                                    width: 150,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Name",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                          letterSpacing: 1
                                        )
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 16),
                                    onPressed: () {}
                                  )
                                ]
                              ),
                              Center(
                                child: Text(
                                  "youremail@gmail.com",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    letterSpacing: 0.3
                                  )
                                )
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        myCoursesSelected
                          ? ButtonTheme(
                              minWidth: 150,
                              height: 31,
                              child: FlatButton(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 2
                                  )
                                ),
                                onPressed: () {},
                                child: Text(
                                  "My Courses",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9,
                                    color: Colors.white
                                  )
                                )
                              ),
                            )
                          : ButtonTheme(
                              minWidth: 150,
                              height: 31,
                              child: FlatButton(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 2
                                  )
                                ),
                                onPressed: () {
                                  setState(() {
                                    myCoursesSelected = !myCoursesSelected;
                                    completedSelected = !completedSelected;
                                  });
                                },
                                child: Text(
                                  "My Courses",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9,
                                    color: Theme.of(context).accentColor
                                  )
                                )
                              ),
                            ),
                        completedSelected
                          ? ButtonTheme(
                              minWidth: 150,
                              height: 31,
                              child: FlatButton(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 2
                                  )
                                ),
                                onPressed: () {},
                                child: Text(
                                  "Completed",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9,
                                    color: Colors.white
                                  )
                                )
                              ),
                            )
                          : ButtonTheme(
                              minWidth: 150,
                              height: 31,
                              child: FlatButton(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Theme.of(context).accentColor,
                                    width: 2
                                  )
                                ),
                                onPressed: () {
                                  setState(() {
                                    myCoursesSelected = !myCoursesSelected;
                                    completedSelected = !completedSelected;
                                  });
                                },
                                child: Text(
                                  "Completed",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9,
                                    color: Theme.of(context).accentColor
                                  )
                                )
                              ),
                            )
                      ],
                    ),
                    SizedBox(height: 20),
                    myCoursesSelected
                      ? FutureBuilder(
                          future: widget.documentReference.collection("Enrolled").getDocuments(),
                          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                      child: Shimmer.fromColors(
                                        baseColor: Color(0xFFCCCCCC),
                                        highlightColor: Color(0xFFE2E2E2),                                
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 55,
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Theme.of(context).accentColor,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  height: 17,
                                                  width: 180,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Theme.of(context).accentColor
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 12,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Theme.of(context).accentColor
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    )
                                  );
                                  break;
                                default:
                                  return snapshot.data.documents.length > 0
                                    ? 
                                    Container(
                                      height: MediaQuery.of(context).size.height - 450,
                                      child: ListView.builder(
                                        itemCount: snapshot.data.documents.length,
                                        itemBuilder: (BuildContext context,int index) {
                                          DocumentReference docRef = snapshot.data.documents[index]["course"];
                                            return FutureBuilder(
                                              future: docRef.get(),
                                              builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot1) {
                                                if (snapshot1.hasData) {
                                                  return ListTile(
                                                    leading: Container(
                                                      width: 45,
                                                      height: 45,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(snapshot1.data["coverImageUrl"])
                                                        )
                                                      ),
                                                    ),
                                                    title: Text(
                                                      snapshot1.data["title"],
                                                      style: GoogleFonts.poppins(
                                                        fontWeight:FontWeight.w600,
                                                        fontSize: 13,
                                                        letterSpacing:0.2
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      snapshot1.data["level"],
                                                      style: GoogleFonts.poppins(
                                                        fontSize:11,
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing:0.2
                                                      )
                                                    ),
                                                    trailing: Transform.rotate(
                                                      angle: 315 * math.pi /180,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.send,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                        onPressed:() {
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CourseContentScreen(snapshot.data.documents[index].reference,snapshot1.data["title"])));
                                                        }
                                                      ),
                                                    ),
                                                  );
                                                } 
                                                else if(snapshot1.hasError){
                                                  return Container(width: 0,height: 0,);
                                                }
                                                else{
                                                  return Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    child: Shimmer.fromColors(
                                                      baseColor: Color(0xFFCCCCCC),
                                                      highlightColor: Color(0xFFE2E2E2),                                
                                                      child: Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 55,
                                                            height: 55,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Theme.of(context).accentColor,
                                                            ),
                                                          ),
                                                          SizedBox(width: 20),
                                                          Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 17,
                                                                width: 180,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(2),
                                                                  color: Theme.of(context).accentColor
                                                                ),
                                                              ),
                                                              SizedBox(height: 10),
                                                              Container(
                                                                height: 12,
                                                                width: 80,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(2),
                                                                  color: Theme.of(context).accentColor
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  );
                                                }
                                              }
                                            );
                                          }
                                        )
                                      )
                                    : Center(
                                      child: Text(
                                        "No documents yet"
                                      )
                                    );
                                  }
                            } 
                            else if (snapshot.hasError) {
                              return Center(
                                child: Text("Oops Error Occured")
                              );
                            } 
                            else {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  child: Shimmer.fromColors(
                                    baseColor: Color(0xFFCCCCCC),
                                    highlightColor: Color(0xFFE2E2E2),                                
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 55,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Theme.of(context).accentColor,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 17,
                                              width: 180,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                color: Theme.of(context).accentColor
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Container(
                                              height: 12,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                color: Theme.of(context).accentColor
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                )
                              );
                            }
                          }
                        )
                      : completed > 0
                          ? FutureBuilder(
                              future: widget.documentReference.collection("Enrolled").getDocuments(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                        child: CircularProgressIndicator()
                                      );
                                      break;
                                    default:
                                      return Container(
                                        height: MediaQuery.of(context).size.height - 450,
                                        child: ListView.builder(
                                          itemCount: snapshot.data.documents.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            DocumentReference docRef = snapshot.data.documents[index]["course"];
                                            return snapshot.data.documents[index]["completed"]
                                              ? FutureBuilder(
                                                  future: docRef.get(),
                                                  builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot1) {
                                                    if (snapshot1.hasData) {
                                                      return ListTile(
                                                        leading: Container(
                                                          width: 45,
                                                          height: 45,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: NetworkImage(snapshot1.data["coverImageUrl"])
                                                            )
                                                          ),
                                                        ),
                                                        title: Text(
                                                          snapshot1.data["title"],
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                            letterSpacing: 0.2
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          snapshot1.data["level"],
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w500,
                                                            letterSpacing: 0.2
                                                          )
                                                        ),
                                                        trailing: Transform.rotate(
                                                          angle: 315 * math.pi / 180,
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons.send,
                                                              color: Theme.of(context).primaryColor,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CourseContentScreen(snapshot.data.documents[index].reference,snapshot1.data["title"])));
                                                            }
                                                          ),
                                                        ),
                                                      );
                                                    } 
                                                    else if(snapshot1.hasError){
                                                      return Container(width: 0, height: 0,);
                                                    }
                                                    else{
                                                      return Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                                        child: Shimmer.fromColors(
                                                          baseColor: Color(0xFFCCCCCC),
                                                          highlightColor: Color(0xFFE2E2E2),                                
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                width: 55,
                                                                height: 55,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  color: Theme.of(context).accentColor,
                                                                ),
                                                              ),
                                                              SizedBox(width: 20),
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Container(
                                                                    height: 17,
                                                                    width: 180,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(2),
                                                                      color: Theme.of(context).accentColor
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 10),
                                                                  Container(
                                                                    height: 12,
                                                                    width: 80,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(2),
                                                                      color: Theme.of(context).accentColor
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      );
                                                    }
                                                  }
                                                )
                                              : Container(
                                                  width: 0, 
                                                  height: 0
                                                );
                                              }
                                            )
                                    );
                                  }
                                } 
                                else if (snapshot.hasError) {
                                  return Center(
                                    child: Text("Oops Error Occured")
                                  );
                                } 
                                else {
                                  return Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                      child: Shimmer.fromColors(
                                        baseColor: Color(0xFFCCCCCC),
                                        highlightColor: Color(0xFFE2E2E2),                                
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 55,
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Theme.of(context).accentColor,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  height: 17,
                                                  width: 180,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Theme.of(context).accentColor
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 12,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Theme.of(context).accentColor
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    )
                                  );
                                }
                              }
                            )
                          : Center(
                              child: Text("No documents yet")
                            )
                  ],
                ),
              ),
            ),
    );
  }
}
