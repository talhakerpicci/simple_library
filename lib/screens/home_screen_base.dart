import 'package:feature_discovery/feature_discovery.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../widgets/custom_app_bar.dart';
import '../values/values.dart';
import '../enums/pop_menu_options.dart';
import '../enums/book_states.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../viewmodels/db_model.dart';
import '../widgets/custom_drawer.dart';

import 'add_book_screen.dart';
import 'book_grid_screen.dart';
import 'search_book_screen.dart';
import 'search_book_online_screen.dart';

class HomeScreenBase extends StatefulWidget {
  @override
  _HomeScreenBaseState createState() => _HomeScreenBaseState();
}

class _HomeScreenBaseState extends State<HomeScreenBase> {
  int _selectedIndex = 0;
  bool _isNewBookAdded = false;
  var cfg;
  final appcastURL = 'https://www.talhakerpicci.com/other/app/appcast.xml';

  @override
  void initState() {
    super.initState();
    cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Utils.initHive();

      Provider.of<UserModel>(context, listen: false).fillUserInfo();
      Provider.of<DbModel>(context, listen: false).init();
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          'initial_feature',
        },
      );

      var box = await Hive.openBox('versionBox');
      String version = box.get('appVersion');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      if (version != currentVersion) {
        await box.put('appVersion', currentVersion);
        Utils.showWhatsNew(context, version: currentVersion);
      }
    });
  }

  void navigateToAddNewBook(UserModel model, Widget screen) async {
    if (model.user.books != null && model.user.books.length >= Utils.maxBookCapacity) {
      String message = model.user.isPremium ? '' : StringConst.upgradeToProToSeeWhy.tr;

      Utils.showFlushInfo(
        context,
        '${StringConst.reachedMaxBookCapacity.tr}: ${Utils.maxBookCapacity}. $message',
      );
      return;
    }
    var data = await Get.to(() => screen);
    if (data != null && data['result']) {
      if (data['action'] == 'insert') {
        Utils.showCustomInfoToast(
          context,
          StringConst.customTranslation(
            data: data['book'],
            key: StringConst.successfullyAddedBook,
          ),
        );
        switch (data['state']) {
          case BookState.Reading:
            setState(() {
              _selectedIndex = 1;
              _isNewBookAdded = true;
            });
            break;
          case BookState.Finished:
            setState(() {
              _selectedIndex = 2;
              _isNewBookAdded = true;
            });
            break;
          case BookState.ToRead:
            setState(() {
              _selectedIndex = 3;
              _isNewBookAdded = true;
            });
            break;
          case BookState.Dropped:
            setState(() {
              _selectedIndex = 4;
              _isNewBookAdded = true;
            });
            break;
          default:
        }
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isNewBookAdded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.appName,
        centerTitle: true,
        actions: [
          DescribedFeatureOverlay(
            featureId: 'initial_feature',
            tapTarget: const Icon(Icons.more_vert),
            title: Text(StringConst.addNewBook.tr),
            description: Text(StringConst.tapHereToAddBook.tr),
            backgroundColor: AppColors.nord2,
            targetColor: Colors.white,
            textColor: Colors.white,
            child: PopupMenuButton(
              onSelected: (Options selectedValue) async {
                if (!model.isAllStatesReady()) {
                  return;
                }

                if (selectedValue == Options.AddNew) {
                  navigateToAddNewBook(model, AddBookScreen());
                } else if (selectedValue == Options.Search) {
                  Get.to(() => SearchBookScreen());
                } else if (selectedValue == Options.SearchOnline) {
                  navigateToAddNewBook(model, SearchBookOnlineScreen());
                }
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: ListTile(
                    title: Container(
                      width: 200,
                      child: Text(
                        StringConst.addNewBook.tr,
                        style: const TextStyle(
                          fontFamily: StringConst.trtRegular,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.add),
                  ),
                  value: Options.AddNew,
                ),
                PopupMenuItem(
                  child: ListTile(
                    title: Container(
                      width: 200,
                      child: Text(
                        StringConst.search.tr,
                        style: TextStyle(
                          fontFamily: StringConst.trtRegular,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.search),
                  ),
                  value: Options.Search,
                ),
                PopupMenuItem(
                  child: ListTile(
                    title: Container(
                      width: 200,
                      child: Text(
                        StringConst.searchBookOnline.tr,
                        style: TextStyle(
                          fontFamily: StringConst.trtRegular,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.public),
                  ),
                  value: Options.SearchOnline,
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      backgroundColor: Colors.white,
      body: UpgradeAlert(
        appcastConfig: cfg,
        showReleaseNotes: false,
        durationToAlertAgain: Duration(days: 2),
        countryCode: Utils.countryCode,
        showIgnore: false,
        messages: UpgraderMessages(
          code: Utils.languageCode,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: BookGridScreen(
                state: BookState.values[_selectedIndex],
                scrollToBottom: _isNewBookAdded,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.nord2,
        unselectedItemColor: AppColors.nord7,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            _isNewBookAdded = false;
          });
        },
        selectedFontSize: 13,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.only(bottom: 4, top: 2),
              child: const Icon(
                FontAwesomeIcons.book,
                size: 18,
              ),
            ),
            label: StringConst.all.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_stories),
            label: StringConst.reading.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cake),
            label: StringConst.finished.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.watch_later),
            label: StringConst.toRead.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.thumb_down),
            label: StringConst.dropped.tr,
          ),
        ],
      ),
    );
  }
}
