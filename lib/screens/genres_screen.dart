import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../widgets/custom_entry_field.dart';
import '../model/models.dart';
import '../widgets/spaces.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';

import 'empty_screen.dart';

class GenresScreen extends StatefulWidget {
  @override
  _GenresScreenState createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  bool _isLoading = false;
  final _form = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: true);
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.genres.tr,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
            ),
            onPressed: () {
              Utils.showFlushInfo(context, StringConst.longPressToEdit.tr);
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var result = await showGenreInputDialog(
                context: context,
                mode: "add",
              );

              if (result) {
                Utils.showCustomInfoToast(context, StringConst.genreInsertSuccess.tr);
              }
            },
          ),
        ],
      ),
      body: model.user.genres.length == 0
          ? EmptyScreen(
              icon: Icons.category,
              description: StringConst.genresWillBeListedHere.tr,
            )
          : LoadingOverlay(
              isLoading: _isLoading,
              color: Colors.white,
              opacity: 0.65,
              progressIndicator: const SpinKitCircle(
                color: AppColors.nord1,
                size: 60,
              ),
              child: ListView.builder(
                itemCount: model.user.genres.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      model.user.genres[index].title,
                      style: const TextStyle(
                        fontFamily: StringConst.trtRegular,
                      ),
                    ),
                    leading: Icon(Icons.category),
                    onLongPress: () async {
                      var result = await showModalBottomSheet<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 130,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.edit,
                                      color: Colors.blue[300],
                                    ),
                                    title: Text(
                                      StringConst.update.tr,
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                    onTap: () {
                                      Get.back(result: 'update');
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red[300],
                                    ),
                                    title: Text(
                                      StringConst.delete.tr,
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                    onTap: () {
                                      Get.back(result: 'delete');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      if (result != null) {
                        if (result == 'update') {
                          var result = await showGenreInputDialog(
                            context: context,
                            mode: "edit",
                            genre: model.user.genres[index],
                            genreName: model.user.genres[index].title,
                          );

                          if (result) {
                            Utils.showCustomInfoToast(context, StringConst.genreUpdateSuccess.tr);
                          }
                        } else if (result == 'delete') {
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
                            } else {
                              setState(() {
                                model.user.genres.insert(index, genre);
                              });
                              Utils.showCustomErrorToast(context, StringConst.genreDeleteFail.tr);
                            }
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}
