import 'package:flutter/material.dart';

import 'spaces.dart';

class StatCard extends StatelessWidget {
  final int firstData;
  final String firstDataType;
  final String firstExplanation;
  final int secondData;
  final String secondDataType;
  final String secondExplanation;
  final List<Color> colors;

  StatCard({
    this.firstData,
    this.firstDataType,
    this.firstExplanation,
    this.secondData,
    this.secondDataType,
    this.secondExplanation,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          const Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 7,
            offset: const Offset(0, 5), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width - 30,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: RichText(
                          text: TextSpan(
                            text: '$firstData ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50),
                            children: <TextSpan>[
                              TextSpan(
                                text: firstDataType,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SpaceH12(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          firstExplanation,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              secondData != null
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: EdgeInsets.only(right: 20),
                              child: RichText(
                                text: TextSpan(
                                  text: '$secondData ',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: secondDataType,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                secondExplanation,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          SpaceH18(),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
