import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import './BankInfo.dart';
import 'dart:convert';
import './BankDetails.dart';

class InfoScreen extends StatefulWidget {
  final String phoneNO;
  InfoScreen(this.phoneNO) : super();

  @override
  _InfoScreenState createState() => new _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String name;
  int selectedRadio;

  @override
  void initState() {
    super.initState();
    selectedRadio = 1;
  }

  setSelectedRadio(int val) => {
        setState(() => {selectedRadio = val})
      };

  _makerequest(BuildContext context) async {
    String keyId = '';
    String keySecret = '';
    String url = 'https://$keyId:$keySecret@api.razorpay.com/v1/contacts';
    Map<String, String> headers = {"Content-type": "application/json"};
    String name = _nameController.text;
    String ing =
        '{"name": "$name","contact":"${widget.phoneNO}","type":"customer"}';
    var response = await http.post(url, headers: headers, body: ing);
    var jsonres = await json.decode(response.body);
    var id1 = jsonres['id'].toString();

    if (id1 != null) {
      if (this.selectedRadio == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BankDetailsScreen(id1)));
      } else if (this.selectedRadio == 2) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BankInfoScreen(id1)));
      }
    }
  }

  String validateName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Image.asset("assets/CCLogo.png"),
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/image_02.png")
            ],
          ),
          SingleChildScrollView(
              child: new Form(
            key: _key,
            autovalidate: _validate,
            child: (Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 150.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(180),
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil.getInstance().setHeight(600),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, 15.0),
                              blurRadius: 15.0),
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, -10.0),
                              blurRadius: 10.0),
                        ]),
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Personal Info",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(45),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(5),
                          ),
                          Text("Name",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: "Name",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.supervisor_account)),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            validator: validateName,
                            onSaved: (String val) {
                              name = val;
                            },
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(25),
                          ),
                          Text("Preferred Payment Method",
                              style: TextStyle(fontFamily: "Poppins-Medium")),
                          RadioListTile(
                            value: 1,
                            groupValue: selectedRadio,
                            title: Text("Bank"),
                            onChanged: (val) {
                              setSelectedRadio(val);
                            },
                            activeColor: Colors.blue,
                          ),
                          RadioListTile(
                            value: 2,
                            groupValue: selectedRadio,
                            title: Text("UPI"),
                            onChanged: (val) {
                              setSelectedRadio(val);
                            },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          width: ScreenUtil.getInstance().setWidth(330),
                          height: ScreenUtil.getInstance().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF17ead9),
                                Color(0xFF6078ea)
                              ]),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_key.currentState.validate()) {
                                  // No any error in validation
                                  _key.currentState.save();
                                  _makerequest(context);
                                } else {
                                  // validation error
                                  setState(() {
                                    _validate = true;
                                  });
                                }
                              },
                              child: Center(
                                child: Text("Proceed",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 18,
                                        letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ))
        ],
      ),
    );
  }
}
