import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';
import '../enums/online_search_option.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';

class CustomOnlineSearchOptionPickerDialog extends StatefulWidget {
  final OnlineSearchOption initialOption;
  CustomOnlineSearchOptionPickerDialog({this.initialOption});
  @override
  _CustomOnlineSearchOptionPickerDialogState createState() => _CustomOnlineSearchOptionPickerDialogState();
}

class _CustomOnlineSearchOptionPickerDialogState extends State<CustomOnlineSearchOptionPickerDialog> {
  OnlineSearchOption _radioVal;

  @override
  void initState() {
    super.initState();
    _radioVal = widget.initialOption;
  }

  dialogContent(BuildContext context, double width, double height) {
    return GestureDetector(
      onTap: () {
        Utils.unFocus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 240,
          width: width * 0.5,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 60,
                color: AppColors.nord4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SpaceW12(),
                    Text(
                      StringConst.onlineSearchLanguage.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Radio(
                            value: OnlineSearchOption.Bookdepository,
                            onChanged: (value) {
                              setState(() {
                                _radioVal = value;
                              });
                            },
                            groupValue: _radioVal,
                          ),
                          title: Text(StringConst.english.tr),
                          onTap: () {
                            setState(() {
                              _radioVal = OnlineSearchOption.Bookdepository;
                            });
                          },
                        ),
                        ListTile(
                          leading: Radio(
                            value: OnlineSearchOption.DR,
                            onChanged: (value) {
                              setState(() {
                                _radioVal = value;
                              });
                            },
                            groupValue: _radioVal,
                          ),
                          title: Text(StringConst.turkish.tr),
                          onTap: () {
                            setState(() {
                              _radioVal = OnlineSearchOption.DR;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                color: AppColors.nord4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Material(
                      color: AppColors.nord4,
                      child: InkWell(
                        highlightColor: AppColors.grey4,
                        onTap: () {
                          Get.back(result: null);
                        },
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
                      color: AppColors.nord4,
                      child: InkWell(
                        highlightColor: AppColors.grey4,
                        onTap: () {
                          Get.back(result: _radioVal);
                        },
                        child: Container(
                          height: 40,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.only(right: 15, left: 15),
                              child: Text(
                                StringConst.save.tr,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    var heightOfScreen = MediaQuery.of(context).size.height;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: dialogContent(context, widthOfScreen, heightOfScreen),
    );
  }
}
