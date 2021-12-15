import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_entry_field.dart';
import '../model/models.dart';
import '../screens/empty_screen.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/spaces.dart';

import 'custom_yes_no_dialog.dart';

class CustomGenrePickerDialog extends StatefulWidget {
  final String selectedId;
  final bool showClearButton;
  CustomGenrePickerDialog({this.selectedId, this.showClearButton = true});
  @override
  _CustomGenrePickerDialogState createState() => _CustomGenrePickerDialogState();
}

class _CustomGenrePickerDialogState extends State<CustomGenrePickerDialog> {
  final _form = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _selectedGenreRemoved = false;
  String _selectedId;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }

  void _scrollToBottom() {
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.ease,
      );
    } catch (e) {}
  }

  Future<bool> showGenreInputDialog({BuildContext context, String mode, Genre genre, String genreName = ''}) async {
    var width = MediaQuery.of(context).size.width;
    var model = Provider.of<UserModel>(context, listen: false);

    bool isLoading = false;

    final TextEditingController genreController = TextEditingController();
    genreController.value = TextEditingValue(text: genreName, selection: genreController.selection);

    var result = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 0.0,
          insetPadding: const EdgeInsets.all(0),
          child: Container(
            height: 220,
            width: width * 0.85,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LoadingOverlay(
                isLoading: isLoading,
                color: Colors.white,
                opacity: 0.65,
                progressIndicator: const SpinKitCircle(
                  color: AppColors.nord1,
                  size: 60,
                ),
                child: Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpaceH18(),
                      Text(
                        mode == 'edit' ? StringConst.editGenre.tr : StringConst.addNewGenre.tr,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const Spacer(),
                      Form(
                        key: _form,
                        child: EntryField(
                          hintText: StringConst.genre.tr,
                          textCapitalization: TextCapitalization.words,
                          icon: const Icon(Icons.category),
                          controller: genreController,
                          onChanged: (value) {
                            setState(() {
                              genreName = value;
                            });
                          },
                          validator: (value) {
                            if (genreName.trim().isEmpty) {
                              return StringConst.genreCanNotBeEmpty.tr;
                            }
                            if (genreName.length > 200) {
                              return StringConst.genreLengthMustBeLowerThan.tr;
                            }
                            if (genre != null && genreName == genre.title) {
                              return null;
                            }
                            if (model.isGenreAlreadyExists(genreName)) {
                              return StringConst.thisGenreAlreadyExists.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                      SpaceH12(),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back(result: false);
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0.0),
                                  ),
                                  alignment: Alignment.bottomCenter,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: <Color>[
                                        Colors.grey[400],
                                        Colors.grey[400],
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      StringConst.cancel.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SpaceW12(),
                          Expanded(
                            child: Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Utils.unFocus();

                                  final isValid = _form.currentState.validate();
                                  if (!isValid) {
                                    return;
                                  }
                                  _form.currentState.save();

                                  if (mode == 'edit') {
                                    if (genreName == genre.title) {
                                      Get.back(result: false);
                                    } else {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      if (!(await Utils.isOnline())) {
                                        Utils.showCustomErrorToast(
                                          context,
                                          StringConst.makeSureYouAreOnline.tr,
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }

                                      var result = await model.updateGenre(
                                        id: genre.id,
                                        genre: Genre(
                                          title: genreName,
                                          dateCreated: genre.dateCreated,
                                        ),
                                      );

                                      if (result.success) {
                                        Get.back(result: true);
                                      } else {
                                        Utils.showCustomErrorToast(context, StringConst.failedToUpdateGenre.tr);
                                      }

                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  } else {
                                    if (model.user.genres.length >= Utils.maxGenreCapacity) {
                                      Utils.showFlushInfo(
                                        context,
                                        '${StringConst.reachedMaxGenreCapacity.tr}: ${Utils.maxGenreCapacity}',
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    if (!(await Utils.isOnline())) {
                                      Utils.showCustomErrorToast(
                                        context,
                                        StringConst.makeSureYouAreOnline.tr,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                      return;
                                    }

                                    var result = await model.addGenre(
                                      genre: Genre(
                                        title: genreName,
                                        dateCreated: DateTime.now(),
                                      ),
                                    );

                                    await Future.delayed(const Duration(milliseconds: 50));

                                    if (result.success) {
                                      Get.back(result: true);
                                    } else {
                                      Utils.showFlushError(
                                        context,
                                        StringConst.couldNotAddGenre.tr,
                                      );
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0.0),
                                  ),
                                ),
                                child: Ink(
                                  decoration: const BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: const <Color>[
                                        AppColors.nord4,
                                        AppColors.nord4,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      mode == 'edit' ? StringConst.update.tr : StringConst.add.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return result;
  }

  Widget dialogContent(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var model = Provider.of<UserModel>(context, listen: true);

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
          child: LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.white,
            opacity: 0.65,
            progressIndicator: const SpinKitCircle(
              color: AppColors.nord1,
              size: 60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: AppColors.nord4,
                  height: 70,
                  alignment: Alignment.center,
                  child: Text(
                    StringConst.chooseGenre.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: model.user.genres.length == 0
                        ? Center(
                            child: EmptyScreen(
                              icon: Icons.category,
                              description: StringConst.genresWillBeListedHere.tr,
                            ),
                          )
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                              crossAxisCount: 2,
                              height: 100,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: model.user.genres.length,
                            itemBuilder: (contex, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(const Radius.circular(12)),
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: _selectedId == model.user.genres[index].id ? AppColors.nord4 : Colors.grey[300],
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10),
                                        ),
                                        highlightColor: AppColors.grey3,
                                        onTap: () {
                                          Get.back(result: model.user.genres[index].id);
                                        },
                                        child: Container(
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              model.user.genres[index].title,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SpaceH8(),
                                    Container(
                                      height: 25,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              Genre genre = model.user.genres[index];

                                              var result = await showDialog(
                                                builder: (context) => CustomYesNoDialog(
                                                  message: '${StringConst.confirmDeletingGenre.tr}: ${genre.title}',
                                                  buttonTitleLeft: StringConst.delete.tr,
                                                  buttonTitleRight: StringConst.cancel.tr,
                                                  leftButtonReturn: true,
                                                  rightButtonReturn: false,
                                                ),
                                                context: context,
                                              );

                                              if (result != null && result) {
                                                setState(() {
                                                  _isLoading = true;
                                                });

                                                if (!(await Utils.isOnline())) {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  Utils.showCustomErrorToast(
                                                    context,
                                                    StringConst.makeSureYouAreOnline.tr,
                                                  );
                                                  return;
                                                }

                                                var result = await model.deleteGenre(id: genre.id);

                                                setState(() {
                                                  _isLoading = false;
                                                });

                                                if (result.success) {
                                                  model.user.genres.remove(genre);
                                                  Utils.showCustomInfoToast(context, StringConst.genreDeleteSuccess.tr);
                                                  if (genre.id == _selectedId) {
                                                    setState(() {
                                                      _selectedId = '';
                                                      _selectedGenreRemoved = true;
                                                    });
                                                  }
                                                } else {
                                                  setState(() {
                                                    model.user.genres.insert(index, genre);
                                                  });
                                                  Utils.showCustomErrorToast(context, StringConst.genreDeleteFail.tr);
                                                }
                                              }
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red[300],
                                            ),
                                          ),
                                          SpaceW12(),
                                          GestureDetector(
                                            onTap: () async {
                                              var result = await showGenreInputDialog(
                                                context: context,
                                                mode: "edit",
                                                genre: model.user.genres[index],
                                                genreName: model.user.genres[index].title,
                                              );

                                              if (result) {
                                                Utils.showCustomInfoToast(context, StringConst.genreUpdateSuccess.tr);
                                              }
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blue[300],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Container(
                  height: 50,
                  color: AppColors.nord4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Material(
                        color: AppColors.nord4,
                        child: InkWell(
                          highlightColor: AppColors.grey3,
                          onTap: () {
                            Get.back(result: _selectedGenreRemoved ? '' : null);
                          },
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.only(left: 15, right: 15),
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
                          highlightColor: AppColors.grey3,
                          onTap: () async {
                            var result = await showGenreInputDialog(
                              context: context,
                              mode: "add",
                            );

                            if (result) {
                              Utils.showCustomInfoToast(context, StringConst.genreInsertSuccess.tr);
                              _scrollToBottom();
                            }
                          },
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.only(right: 15, left: 15),
                                child: Text(
                                  StringConst.addNewGenre.tr,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.back(result: _selectedGenreRemoved ? '' : null);
        return Future.value(true);
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0.0,
        insetPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
      ),
    );
  }
}

class SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// All of the arguments must not be null. The `mainAxisSpacing` and
  /// `crossAxisSpacing` arguments must not be negative. The `crossAxisCount`
  /// and `childAspectRatio` arguments must be greater than zero.
  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight({
    @required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.height = 56.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(height != null && height > 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The height of the crossAxis.
  final double height;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(height > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = height;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount || oldDelegate.mainAxisSpacing != mainAxisSpacing || oldDelegate.crossAxisSpacing != crossAxisSpacing || oldDelegate.height != height;
  }
}
