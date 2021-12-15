import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';

class CustomInputDialog extends StatefulWidget {
  final String headTitle;
  final List<Widget> children;
  final Icon icon;
  final double width;
  final double height;
  final Function onSave;
  final Function onCancel;
  final bool showBottomButtons;
  CustomInputDialog({this.headTitle, this.children, this.icon, this.width, this.height, this.onCancel, this.onSave, this.showBottomButtons = true});
  @override
  _CustomInputDialogState createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<CustomInputDialog> {
  @override
  void initState() {
    super.initState();
  }

  dialogContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Utils.unFocus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          height: widget.height,
          width: widget.width,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 60,
                color: AppColors.grey2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SpaceW12(),
                    Text(
                      widget.headTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    widget.icon != null ? widget.icon : Container(),
                    SpaceW12(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        ...widget.children,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 30,
                color: AppColors.grey2,
                child: widget.showBottomButtons
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Material(
                            color: AppColors.grey2,
                            child: InkWell(
                              highlightColor: AppColors.grey4,
                              onTap: widget.onCancel,
                              child: Container(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 15, left: 15),
                                    child: Text(
                                      StringConst.cancel.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: AppColors.grey2,
                            child: InkWell(
                              highlightColor: AppColors.grey4,
                              onTap: widget.onSave,
                              child: Container(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 15, left: 15),
                                    child: Text(
                                      StringConst.done.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
