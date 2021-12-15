import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../model/models.dart';
import '../widgets/custom_app_bar.dart';

import 'empty_screen.dart';

class MostCommonDataScreen extends StatelessWidget {
  final String title;
  final Map data;
  final List sortedKeys;
  final Icon liteTileIcon;
  final bool isGenre;
  final List allGenres;
  MostCommonDataScreen({
    this.title,
    this.data,
    this.sortedKeys,
    this.liteTileIcon,
    this.isGenre = false,
    this.allGenres,
  });

  String getGenre(List<Genre> genres, String selectedGenre) {
    String genre;
    try {
      genre = genres.firstWhere((item) => item.id == selectedGenre).title;
    } catch (e) {
      genre = '';
    }
    return genre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title),
      body: data.keys.length == 0
          ? EmptyScreen(
              icon: isGenre ? Icons.category : Icons.person,
              description: StringConst.notEnoughDataToDisplay.tr,
            )
          : ListView.builder(
              itemCount: data.keys.length,
              itemBuilder: (context, index) {
                String title = sortedKeys[index];
                if (isGenre) {
                  title = getGenre(allGenres, sortedKeys[index]);
                  if (title == '') {
                    return Container();
                  }
                }
                return ListTile(
                  title: Text(
                    isGenre ? getGenre(allGenres, sortedKeys[index]) : '${sortedKeys[index]}',
                    style: TextStyle(
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                  trailing: Text('${data[sortedKeys[index]]}'),
                  leading: liteTileIcon,
                );
              }),
    );
  }
}
