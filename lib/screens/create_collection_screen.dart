import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../model/models.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../dialogs/custom_error_dialog.dart';
import '../widgets/custom_book_card_vertical.dart';
import '../widgets/custom_entry_field.dart';
import '../widgets/spaces.dart';

import 'select_books_screen.dart';

class CreateColectionScreen extends StatefulWidget {
  final Collection collection;

  CreateColectionScreen({
    this.collection,
  });
  @override
  _CreateColectionScreenState createState() => _CreateColectionScreenState();
}

class _CreateColectionScreenState extends State<CreateColectionScreen> {
  Collection collection;
  bool _isLoading = false;

  final _form = GlobalKey<FormState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.collection != null) {
      collection = Collection.fromJson(
        id: widget.collection.id,
        json: widget.collection.toJson(),
      );
    } else {
      collection = Collection(
        books: [],
      );
    }

    _titleController.value = TextEditingValue(text: collection.title, selection: _titleController.selection);
    _descriptionController.value = TextEditingValue(text: collection.description, selection: _descriptionController.selection);
  }

  void showErrorDialog(String message) {
    showDialog(
      builder: (context) => ErrorDialog(message),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var model = Provider.of<UserModel>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.collection != null ? StringConst.editCollection.tr : StringConst.createCollection.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final isValid = _form.currentState.validate();
              if (!isValid) {
                return;
              }

              Utils.unFocus();

              if (!(await Utils.isOnline())) {
                Utils.showFlushError(
                  context,
                  StringConst.makeSureYouAreOnline.tr,
                );
                return;
              }

              if (widget.collection == null) {
                showDialog(
                  builder: (context) => WillPopScope(
                    onWillPop: () {
                      return Future.value(false);
                    },
                    child: Dialog(
                      child: Container(
                        width: width,
                        height: 240,
                        child: Column(
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              child: FlareActor(
                                StringConst.flareBookPlaceholder,
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                animation: "Animations",
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const SpinKitPouringHourglass(
                                    color: AppColors.nord0,
                                    size: 35,
                                  ),
                                  SpaceW20(),
                                  Flexible(
                                    child: Container(
                                      child: Text(
                                        StringConst.preparingCollection.tr,
                                        style: const TextStyle(
                                          fontSize: 14,
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
                  context: context,
                );

                collection.dateCreated = DateTime.now();
                var result = await model.addCollecion(collection: collection);

                await Future.delayed(const Duration(milliseconds: 3000));

                Get.back();

                if (result.success) {
                  Get.back(result: {
                    'success': true,
                    'mode': 'insert',
                  });
                } else {
                  Get.back(result: {
                    'success': false,
                    'mode': 'insert',
                  });
                }
              } else {
                if (collection == widget.collection) {
                  Get.back();
                } else {
                  setState(() {
                    _isLoading = true;
                  });

                  var result = await model.updateCollection(
                    id: collection.id,
                    collection: collection,
                  );

                  if (result) {
                    Get.back(result: {
                      'success': true,
                      'mode': 'update',
                    });
                  } else {
                    Get.back(result: {
                      'success': false,
                      'mode': 'update',
                    });
                  }

                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Utils.unFocus();
        },
        child: LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.white,
          opacity: 0.65,
          progressIndicator: const SpinKitCircle(
            color: AppColors.nord1,
            size: 60,
          ),
          child: Container(
            width: width,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Column(
                            children: [
                              SpaceH30(),
                              CustomTextField(
                                labelText: StringConst.colectionName.tr,
                                focusNode: _titleFocusNode,
                                controller: _titleController,
                                textInputAction: TextInputAction.next,
                                textFieldTextStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    collection.title = value;
                                  });
                                },
                                onSubmit: (_) {
                                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return StringConst.thisFieldIsRequired.tr;
                                  }
                                  return null;
                                },
                              ),
                              SpaceH18(),
                              CustomTextField(
                                labelText: StringConst.description.tr,
                                focusNode: _descriptionFocusNode,
                                controller: _descriptionController,
                                textInputAction: TextInputAction.done,
                                textFieldTextStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    collection.description = value;
                                  });
                                },
                                onSubmit: (_) {
                                  Utils.unFocus();
                                },
                              ),
                              SpaceH24(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.collection != null ? StringConst.booksInsideCollection.tr : StringConst.booksToAddColleciton.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: StringConst.trtRegular,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: const Divider(
                                  thickness: 1.2,
                                ),
                              ),
                              SpaceH8(),
                              Container(
                                width: width,
                                height: 150,
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10.0),
                                          onTap: () async {
                                            var result = await Get.to(() => SelectBooksScreen(
                                                  selectedBooks: collection.books,
                                                ));

                                            if (result != null) {
                                              setState(() {
                                                collection.books = result;
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                color: AppColors.grey2,
                                              ),
                                            ),
                                            child: Icon(
                                              collection.books.length == 0 ? Icons.add : Icons.edit,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...collection.books.map((bookId) {
                                        Book book = model.user.books.firstWhere((book) => book.id == bookId);
                                        return Container(
                                          height: 140,
                                          width: 90,
                                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          child: CustomBookCardVertical(
                                            book: book,
                                            customOnTap: () {},
                                            showSmallIcon: true,
                                            shrinkBottom: true,
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
