import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:toeic_app/part/app_bar.dart';

import './../constants.dart';
import 'question_frame.dart';

class PartSeven extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const PartSeven({super.key, required this.data});

  @override
  State<PartSeven> createState() => _PartSevenState();
}

class _PartSevenState extends State<PartSeven> {
  int _curr = 1;
  String numAnswers = '1-2';
  int totalQues = 54;
  List<String> _answer = [];
  PageController controllerFrame = PageController();
  bool isShow = false;
  late List<String> rightAnswerSelect;

  void callbackAnswer(int number, String ans) {
    setState(() {
      _answer[number] = ans;
      print(_answer);
    });
  }

  @override
  void initState() {
    for (int i = 0; i < totalQues; i++) {
      _answer.add("");
    }
    super.initState();
    rightAnswerSelect = compareAnswersToRightAnswers();
  }

  List<String> compareAnswersToRightAnswers() {
    List<String> rightAns = [];
    for (int i = 0; i < widget.data.length; i++) {
      for (int k = 0;
          k < widget.data.elementAt(i)['list_answers'].length;
          k++) {
        for (int j = 0; j < 4; j++) {
          if (widget.data.elementAt(i)['list_right_answer'][k] ==
              widget.data.elementAt(i)['list_answers'][k][j]) {
            if (j == 0) {
              rightAns.add("A");
            } else if (j == 1) {
              rightAns.add("B");
            } else if (j == 2) {
              rightAns.add("C");
            } else {
              rightAns.add("D");
            }
          }
        }
      }
    }
    return rightAns;
  }

  @override
  Widget build(BuildContext context) {
    _curr = 0;
    return Scaffold(
        appBar: AppBarPractice(
          numAnswers: numAnswers,
          answers: listDirectionEng,
          ansTrans: listDirectionVn,
        ),
        body: PageView(
            scrollDirection: Axis.horizontal,
            controller: controllerFrame,
            onPageChanged: (number) {
              setState(() {
                int numAnswerCurrent = 1;
                for (int i = 0; i < number; i++) {
                  numAnswerCurrent += convertListDynamicToListListString(
                          widget.data[i]['list_answers'])
                      .length;
                }
                numAnswers =
                    '$numAnswerCurrent - ${numAnswerCurrent + convertListDynamicToListListString(widget.data[number]['list_answers']).length - 1}';
              });
            },
            children: [
              for (int i = 0; i < widget.data.length; i++)
                PartSevenFrame(
                  number: [
                    for (int j = 0;
                        j <
                            convertListDynamicToListListString(
                                    widget.data[i]['list_answers'])
                                .length;
                        j++)
                      _curr++
                  ],
                  img: [
                    for (int j = 0;
                        j <
                            convertListDynamicToListString(
                                    widget.data[i]['images'])
                                .length;
                        j++)
                      "assets/img/test_1.jpg"
                  ],
                  question: convertListDynamicToListString(
                      widget.data[i]['list_question']),
                  answers: convertListDynamicToListListString(
                      widget.data[i]['list_answers']),
                  rightAnswersSelect: rightAnswerSelect,
                  getAnswer: (number, value) => callbackAnswer(number, value),
                  ans: _answer,
                  isShow: isShow,
                  cancelShowExplan: (s) {
                    setState(() {
                      isShow = s;
                    });
                  },
                ),
            ]));
  }
}

class PartSevenFrame extends StatefulWidget {
  final List<int> number;
  final List<String> question, img, ans, rightAnswersSelect;
  final List<List<String>> answers;
  final Function(int, String) getAnswer;
  final Function(bool) cancelShowExplan;

  final bool isShow;
  // Note, reason

  const PartSevenFrame(
      {super.key,
      required this.number,
      required this.question,
      required this.answers,
      required this.getAnswer,
      required this.img,
      required this.rightAnswersSelect,
      required this.ans,
      required this.cancelShowExplan,
      required this.isShow});

  @override
  State<PartSevenFrame> createState() => _PartSevenFrameState();
}

// --------------------------------------------------------------------
class _PartSevenFrameState extends State<PartSevenFrame> {
  PageController controllerAnswer = PageController();
  late int _currAns;
  FirebaseStorage storage = FirebaseStorage.instance;
  String imageURL = "";
  @override
  void initState() {
    init();
    super.initState();
    _currAns = widget.number[0];
  }

  void init() async {
    String url = await storage.ref().child('img/1.jpg').getDownloadURL();

    setState(() {
      imageURL = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: BoxConstraints(
                          minHeight: 50,
                          maxHeight: MediaQuery.of(context).size.height * 0.4),
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                      child: SingleChildScrollView(
                          child: Center(
                        child: Column(
                          children: [
                            for (int i = 0; i < widget.img.length; i++)
                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: imageURL != ""
                                    ? Image.network(imageURL,
                                        width: 340,
                                        height: 300,
                                        fit: BoxFit.fill)
                                    : SizedBox(
                                        width: 340,
                                        height: 300,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )),
                              )
                          ],
                        ),
                      )),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 2,
                      decoration: BoxDecoration(color: colorApp),
                      child: Text(""),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                              minHeight: 50,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.28),
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                          child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0;
                                      i < widget.question.length;
                                      i++)
                                    QuestionFrame(
                                      number: widget.number[i] + 1,
                                      question: widget.question[i],
                                      answers: widget.answers[i],
                                    ),
                                ]),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),

          // --------- Answer ---------
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (int index in widget.number)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _currAns = index;
                            });
                            controllerAnswer
                                .jumpToPage(_currAns - widget.number[0]);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            margin: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                                border: (_currAns == index)
                                    ? Border(
                                        bottom:
                                            BorderSide(color: orange, width: 5))
                                    : Border.symmetric()),
                            child: Row(
                              children: [
                                Text(
                                  'Q.${index + 1}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color:
                                          (_currAns == index) ? orange : black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    height: 73.6,
                    decoration: BoxDecoration(
                      color: colorBox,
                      boxShadow: [
                        BoxShadow(
                          color: colorBoxShadow,
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 3), // changes position of shadow
                        )
                      ],
                    ),
                    child: PageView(
                        controller: controllerAnswer,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (number) {
                          setState(() {
                            _currAns = widget.number[number];
                          });
                        },
                        children: [
                          for (int size = 0;
                              size < widget.number.length;
                              size++)
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  for (var i in answersOption)
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            widget.getAnswer(
                                                widget.number[size], i);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: widget.ans[widget
                                                              .number[size]] !=
                                                          "" &&
                                                      i ==
                                                          widget.rightAnswersSelect[
                                                              widget
                                                                  .number[size]]
                                                  ? green
                                                  : (widget.ans[widget
                                                              .number[size]] !=
                                                          "")
                                                      ? (i ==
                                                              widget.ans[widget
                                                                  .number[size]]
                                                          ? red
                                                          : white)
                                                      : white,
                                              border: Border.all(
                                                  color: black, width: 1.3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorBoxShadow,
                                                  spreadRadius: 2,
                                                  blurRadius: 3,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                )
                                              ],
                                            ),
                                            child: Text(
                                              i,
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ]),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ]);
  }
}
