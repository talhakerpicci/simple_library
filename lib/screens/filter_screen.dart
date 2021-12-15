import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_button.dart';
import '../enums/book_states.dart';
import '../dialogs/custom_book_state_dialog.dart';
import '../dialogs/custom_genre_picker_dialog.dart';
import '../model/models.dart';
import '../widgets/custom_entry_field.dart';
import '../widgets/spaces.dart';
import '../viewmodels/user_model.dart';
import '../values/values.dart';
import '../utils/utils.dart';
import '../widgets/custom_app_bar.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _isStateCleared = false;
  bool _isGenreCleared = false;
  Map<String, dynamic> filterMap = Map.from(Utils.filter);

  List<String> allAuthors = [];

  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authorController.value = TextEditingValue(text: filterMap['author'], selection: _authorController.selection);
    _pageCountController.value = TextEditingValue(text: filterMap['page-count'] != 0 ? filterMap['page-count'].toString() : '', selection: _pageCountController.selection);

    var model = Provider.of<UserModel>(context, listen: false);
    allAuthors = model.getAllAuthors();
  }

  String _getGenre(List<Genre> genres) {
    String genre;
    try {
      genre = genres.firstWhere((item) => item.id == filterMap['genre']).title;
    } catch (e) {
      genre = '';
    }
    return genre;
  }

  Widget _settingButton({bool isActive, IconData icon, Function onTap, double paddingLeft = 0}) {
    return Container(
      width: 34,
      height: 34,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  width: isActive ? 1.5 : 0.5,
                  color: isActive ? Colors.grey[800] : Colors.grey[400],
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(left: paddingLeft),
                child: Center(
                  child: Icon(
                    icon,
                    color: isActive ? Colors.grey[800] : Colors.grey[400],
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.filters.tr,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                Utils.clearAllFilters(filterMap);
                _authorController.value = TextEditingValue(text: filterMap['author'], selection: _authorController.selection);
                _pageCountController.clear();
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Utils.unFocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            child: Column(
              children: [
                FormField(
                  builder: (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _authorController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              setState(() {
                                filterMap['author'] = value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              border: InputBorder.none,
                              fillColor: AppColors.grey4,
                              filled: true,
                              labelText: StringConst.author.tr,
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return allAuthors.where((author) => author.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder: (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              filterMap['author'] = suggestion;
                              _authorController.value = TextEditingValue(text: suggestion, selection: _authorController.selection);
                            });
                          },
                          hideOnEmpty: true,
                          onSaved: (value) => filterMap['author'] = value,
                        ),
                      ),
                      state.errorText != null
                          ? Container(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                state.errorText,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                SpaceH10(),
                EntryField(
                  hintText: StringConst.state.tr,
                  icon: const Icon(Icons.auto_stories),
                  readOnly: true,
                  textEditingValue: Utils.getBookState(filterMap['state']),
                  showSuffixIcon: Utils.getBookState(filterMap['state']) != '',
                  onSuffixIconTap: () {
                    Utils.unFocus();
                    setState(() {
                      _isStateCleared = true;
                      filterMap['state'] = BookState.All;
                    });
                  },
                  onTap: () async {
                    if (!_isStateCleared) {
                      var result = await showDialog(
                        context: context,
                        builder: (BuildContext context) => BookStateDialog(
                          bookState: filterMap['state'],
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          filterMap['state'] = result;
                        });
                      }
                    }
                    _isStateCleared = false;
                    Utils.unFocus();
                  },
                ),
                SpaceH10(),
                EntryField(
                  hintText: StringConst.genre.tr,
                  icon: const Icon(Icons.category),
                  textEditingValue: filterMap['genre'] != '' ? _getGenre(model.user.genres) : '',
                  showSuffixIcon: filterMap['genre'] != '',
                  onSuffixIconTap: () {
                    Utils.unFocus();
                    setState(() {
                      _isGenreCleared = true;
                      filterMap['genre'] = '';
                    });
                  },
                  readOnly: true,
                  onTap: () async {
                    if (!_isGenreCleared) {
                      var result = await showDialog(
                        context: context,
                        builder: (BuildContext context) => CustomGenrePickerDialog(
                          selectedId: filterMap['genre'] == '' ? '' : filterMap['genre'],
                          showClearButton: false,
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          filterMap['genre'] = result;
                        });
                      }
                    }
                    _isGenreCleared = false;
                    Utils.unFocus();
                  },
                ),
                SpaceH10(),
                Container(
                  child: Row(
                    children: [
                      Text(StringConst.hasNotes.tr),
                      Spacer(),
                      Switch(
                        value: filterMap['has-notes'],
                        activeColor: AppColors.nord1,
                        onChanged: (value) {
                          setState(() {
                            filterMap['has-notes'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Text(StringConst.hasHighlights.tr),
                      Spacer(),
                      Switch(
                        value: filterMap['has-highlits'],
                        activeColor: AppColors.nord1,
                        onChanged: (value) {
                          setState(() {
                            filterMap['has-highlits'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SpaceH10(),
                Container(
                  child: Row(
                    children: [
                      Text(StringConst.ratingColon.tr),
                      SpaceW16(),
                      RatingBar.builder(
                        unratedColor: Colors.grey[300],
                        initialRating: filterMap['rating'],
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 20,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            filterMap['rating'] = rating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SpaceH14(),
                Container(
                  child: Row(
                    children: [
                      Text(StringConst.pageCountColon.tr),
                      SpaceW16(),
                      _settingButton(
                        icon: Icons.arrow_back_ios,
                        isActive: filterMap['show-lower'],
                        paddingLeft: 8,
                        onTap: () {
                          setState(() {
                            filterMap['show-lower'] = !filterMap['show-lower'];
                            if (filterMap['show-lower'] && filterMap['show-higher']) {
                              filterMap['show-higher'] = false;
                            }
                          });
                        },
                      ),
                      SpaceW10(),
                      CustomTextFormField(
                        textAlign: TextAlign.center,
                        width: 60,
                        contentPadding: const EdgeInsets.only(bottom: 5),
                        keyboardType: TextInputType.number,
                        digitsOnly: true,
                        controller: _pageCountController,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 40,
                        ),
                        textCapitalization: TextCapitalization.none,
                        onChanged: (value) {
                          if (value == '') {
                            setState(() {
                              filterMap['page-count'] = 0;
                            });
                          } else {
                            setState(() {
                              filterMap['page-count'] = int.parse(value);
                            });
                          }
                        },
                      ),
                      SpaceW10(),
                      _settingButton(
                        icon: Icons.arrow_forward_ios,
                        isActive: filterMap['show-higher'],
                        onTap: () {
                          setState(() {
                            filterMap['show-higher'] = !filterMap['show-higher'];
                            if (filterMap['show-higher'] && filterMap['show-lower']) {
                              filterMap['show-lower'] = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SpaceH40(),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: CustomButton(
                    height: 40,
                    title: StringConst.apply.tr,
                    onPressed: () {
                      if ((filterMap['show-higher'] || filterMap['show-lower']) && filterMap['page-count'] == 0) {
                        filterMap['show-higher'] = false;
                        filterMap['show-lower'] = false;
                      }

                      Utils.filter = filterMap;
                      Get.back();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
