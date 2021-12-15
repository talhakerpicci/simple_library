import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../enums/viewstate.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/spaces.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_collection_card.dart';

import 'collection_screen.dart';
import 'create_collection_screen.dart';
import 'error_screen.dart';

class CollectionsScreen extends StatefulWidget {
  @override
  _CollectionsScreennState createState() => _CollectionsScreennState();
}

class _CollectionsScreennState extends State<CollectionsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UserModel model = Provider.of<UserModel>(context, listen: false);

    if (model.user.getCollectionsViewState != ViewState.Ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserModel>(context, listen: false).getCollections();
      });
    }
  }

  Widget buildBody() {
    UserModel model = Provider.of<UserModel>(context, listen: true);

    Widget screen;
    if (model.user.getCollectionsViewState == ViewState.Busy) {
      screen = CustomProgressIndicator();
    } else if (model.user.getCollectionsViewState == ViewState.Ready) {
      if (model.user.collections.length == 0) {
        screen = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    StringConst.bookCollectionHighRes,
                    color: AppColors.nord0,
                  ),
                ),
              ),
              SpaceH24(),
              Text(
                StringConst.yourColelctionsWillBeListedHere.tr,
                textAlign: TextAlign.center,
              ),
              SpaceH24(),
              Text(
                StringConst.someIdeas.tr,
                textAlign: TextAlign.left,
              ),
              SpaceH10(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  StringConst.collectionIdea.tr,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      } else {
        screen = LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.white,
          opacity: 0.65,
          progressIndicator: const SpinKitCircle(
            color: AppColors.nord1,
            size: 60,
          ),
          child: Container(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: model.user.collections.length,
              itemBuilder: (context, index) {
                return CustomCollectionCard(
                  collection: model.user.collections[index],
                  onEdit: () async {
                    var result = await Get.to(() => CreateColectionScreen(
                          collection: model.user.collections[index],
                        ));

                    if (result != null) {
                      if (result['success']) {
                        Utils.showCustomInfoToast(context, StringConst.collectionUpdateSuccess.tr);
                      } else {
                        Utils.showCustomErrorToast(context, StringConst.collectionUpdateFail.tr);
                      }
                    }
                  },
                  onOpen: () {
                    Get.to(() => CollectionScreen(
                          collection: model.user.collections[index],
                        ));
                  },
                  onDelete: () async {
                    var result = await showDialog(
                      builder: (context) => CustomYesNoDialog(
                        buttonTitleLeft: StringConst.yes.tr,
                        buttonTitleRight: StringConst.no.tr,
                        message: StringConst.customTranslation(
                          data: model.user.collections[index].title,
                          key: StringConst.deleteCollectionDialog,
                        ),
                      ),
                      context: context,
                    );
                    if (result != null && result) {
                      setState(() {
                        _isLoading = true;
                      });

                      if (!(await Utils.isOnline())) {
                        Utils.showFlushError(
                          context,
                          StringConst.makeSureYouAreOnline.tr,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      var result = await model.deleteCollection(id: model.user.collections[index].id);

                      if (result) {
                        Utils.showCustomInfoToast(context, StringConst.collectionDeleteSuccess.tr);
                      } else {
                        Utils.showCustomErrorToast(context, StringConst.collectionDeleteFail.tr);
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                );
              },
            ),
          ),
        );
      }
    } else if (model.user.getCollectionsViewState == ViewState.Error) {
      screen = ErrorScreen(
        function: model.getCollections,
      );
    }

    return screen;
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.collections.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (!model.isAllStatesReady()) {
                return;
              }

              if (model.user.collections != null && model.user.collections.length >= Utils.maxCollectionCapacity) {
                Utils.showFlushInfo(
                  context,
                  '${StringConst.reachedMaxColelctionCapacity.tr}: ${Utils.maxCollectionCapacity}',
                );
                return;
              }

              var result = await Get.to(() => CreateColectionScreen());
              if (result != null) {
                if (result['success']) {
                  Utils.showCustomInfoToast(context, StringConst.collectionCreateSuccess.tr);
                } else {
                  Utils.showCustomErrorToast(context, StringConst.collectionCreateFail.tr);
                }
              }
            },
          ),
        ],
      ),
      body: buildBody(),
    );
  }
}
