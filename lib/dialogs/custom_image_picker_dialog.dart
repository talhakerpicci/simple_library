import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_network_image.dart';
import '../widgets/spaces.dart';

class CustomImagePickerDialog extends StatefulWidget {
  final List imgLinks;
  CustomImagePickerDialog({this.imgLinks});
  @override
  _CustomImagePickerDialogState createState() => _CustomImagePickerDialogState();
}

class _CustomImagePickerDialogState extends State<CustomImagePickerDialog> {
  String _selectedImg = '';

  Widget getBookCard({String url}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CustomNetworkImage(
          url: url,
        ),
      ),
    );
  }

  dialogContent(BuildContext context, double width, double height) {
    return GestureDetector(
      onTap: () {
        Utils.unFocus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: height * 0.8,
          width: width * 0.9,
          color: Colors.white,
          child: DefaultTabController(
            length: 2,
            child: Builder(
              builder: (BuildContext context) => Column(
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
                          StringConst.selectABookCover.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(12.0),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1 / 1.5,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: widget.imgLinks.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final TabController controller = DefaultTabController.of(context);
                                      setState(() {
                                        _selectedImg = widget.imgLinks[index];
                                      });
                                      await Future.delayed(const Duration(milliseconds: 50));
                                      if (!controller.indexIsChanging) {
                                        controller.animateTo(1);
                                      }
                                    },
                                    child: getBookCard(
                                      url: widget.imgLinks[index],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        _selectedImg == ''
                            ? Center(
                                child: Container(
                                  child: Text(StringConst.selectACoverToApply.tr),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(),
                                  Center(
                                    child: Container(
                                      width: width * 0.6,
                                      height: height * 0.5,
                                      child: getBookCard(
                                        url: _selectedImg,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SpaceW16(),
                                      Expanded(
                                        child: CustomButton(
                                          title: StringConst.chooseAnother.tr,
                                          borderRadius: 5,
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                          onPressed: () async {
                                            final TabController controller = DefaultTabController.of(context);
                                            if (!controller.indexIsChanging) {
                                              controller.animateTo(0);
                                            }
                                          },
                                        ),
                                      ),
                                      SpaceW12(),
                                      Expanded(
                                        child: CustomButton(
                                          title: StringConst.applyCover.tr,
                                          borderRadius: 5,
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                          onPressed: () {
                                            Get.back(result: _selectedImg);
                                          },
                                        ),
                                      ),
                                      SpaceW16(),
                                    ],
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  SpaceH12(),
                ],
              ),
            ),
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
