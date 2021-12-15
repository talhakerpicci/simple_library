import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/info_screen.dart';
import '../enums/viewstate.dart';
import '../screens/goals_screen.dart';
import '../screens/highlights_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../locator.dart';
import '../screens/collections_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/api.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../dialogs/custom_yes_no_dialog.dart';

import 'custom_media_icon.dart';
import 'spaces.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: true);
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              AppColors.nord7,
              AppColors.nord1,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  SpaceH40(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        SpaceW20(),
                        Container(
                          width: 90,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                  return Get.to(() => UserProfileScreen());
                                },
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: ClipOval(
                                    child: Utils.getAvatarImage(
                                      model.user.getUserDataViewState != ViewState.Ready ? '' : model.user.image,
                                      Colors.white,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(const Radius.circular(50.0)),
                                    border: Border.all(
                                      color: model.user.getUserDataViewState != ViewState.Ready
                                          ? Colors.transparent
                                          : model.user.image == ''
                                              ? Colors.transparent
                                              : Colors.white,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              model.user.isPremium
                                  ? Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.yellow[700],
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpaceH14(),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Text(
                      model.user.getUserDataViewState != ViewState.Ready ? StringConst.loading.tr : '${model.user.nameSurname}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SpaceH8(),
                  Container(
                    padding: const EdgeInsets.only(
                      right: 10,
                      left: 10,
                      top: 10,
                    ),
                    child: const Divider(
                      color: Colors.white,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            StringConst.profile.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: StringConst.trtRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            Get.to(() => UserProfileScreen());
                          },
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  child: const Icon(
                                    FontAwesomeIcons.highlighter,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              StringConst.highlights.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: StringConst.trtRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                              Get.to(() => HighlightsScreen());
                            }),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  child: const Icon(
                                    FontAwesomeIcons.medal,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              StringConst.goals.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: StringConst.trtRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                              Get.to(() => GoalsScreen());
                            }),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                                child: const Icon(
                                  Icons.insert_chart,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              StringConst.statistics.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: StringConst.trtRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                              Get.to(() => StatsScreen());
                            }),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  child: Image.asset(
                                    StringConst.bookCollection,
                                    width: 22,
                                    height: 22,
                                    color: Colors.white,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              StringConst.collections.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: StringConst.trtRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                              Get.to(() => CollectionsScreen());
                            }),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            StringConst.settings.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: StringConst.trtRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            Get.to(() => SettingsScreen());
                          },
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.white)),
                              child: const Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            StringConst.logout.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: StringConst.trtRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () async {
                            Get.back();
                            var result = await showDialog(
                              builder: (context) => CustomYesNoDialog(
                                buttonTitleLeft: StringConst.yes.tr,
                                buttonTitleRight: StringConst.no.tr,
                                message: StringConst.confirmExit.tr,
                              ),
                              context: context,
                            );
                            if (result != null && result) {
                              model.clearUserData();
                              imageCache.clear();
                              imageCache.clearLiveImages();

                              await locator<Api>().signOut();
                              Get.offAll(() => WelcomeScreen(removeNotifs: true));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 75,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: const Divider(
                      color: Colors.white,
                      thickness: 0,
                      height: 1,
                    ),
                  ),
                  SpaceH12(),
                  Row(
                    children: <Widget>[
                      SpaceW12(),
                      CustomMediaIcon(
                        icon: const FaIcon(FontAwesomeIcons.googlePlay, color: Colors.white),
                        onTap: () async {
                          await launch(StringConst.appLink);
                        },
                      ),
                      SpaceW12(),
                      CustomMediaIcon(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onTap: () {
                          Share.share(StringConst.appLink);
                        },
                      ),
                      SpaceW12(),
                      CustomMediaIcon(
                        icon: const Icon(FontAwesomeIcons.question, color: Colors.white),
                        onTap: () {
                          Get.back();
                          Get.to(() => InfoScreen());
                        },
                      ),
                      SpaceW12(),
                      CustomMediaIcon(
                        icon: const Icon(FontAwesomeIcons.github, color: Colors.white),
                        onTap: () async {
                          await launch(StringConst.githubLink);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
