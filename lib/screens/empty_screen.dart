import 'package:flutter/material.dart';

import '../values/values.dart';
import '../widgets/spaces.dart';

class EmptyScreen extends StatelessWidget {
  final String description;
  final IconData icon;
  EmptyScreen({this.description, this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 120,
            height: 100,
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 100,
                color: AppColors.nord3,
              ),
            ),
          ),
          SpaceH24(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
