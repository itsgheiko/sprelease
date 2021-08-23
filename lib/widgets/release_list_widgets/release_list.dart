// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Widgets
import './release_widget.dart';

// Models
import 'package:sprelease/models/release.dart';

// Theme
import 'package:sprelease/app_theme.dart';

class ReleaseList extends StatefulWidget {
  final List<Release> thisWeeksReleases, lastWeeksReleases, twoWeeksAgoReleases, threeWeeksAgoReleases, olderReleases;
  final String errorMsg;

  ReleaseList({
    this.errorMsg,
    this.thisWeeksReleases,
    this.lastWeeksReleases,
    this.twoWeeksAgoReleases,
    this.threeWeeksAgoReleases,
    this.olderReleases,
  });

  @override
  _ReleaseListState createState() => _ReleaseListState();
}

class _ReleaseListState extends State<ReleaseList> {
  @override
  Widget build(BuildContext context) {
    Widget dateTitle(String title) {
      return Container(
        margin: EdgeInsets.only(top: 5, left: 20, bottom: 10),
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget releaseList(List<Release> releaseList) {
      return Column(
        children: List.generate(
          releaseList.length,
          (index) {
            return ReleaseWidget(
              Release(
                name: releaseList[index].name,
                artists: releaseList[index].artists,
                id: releaseList[index].id,
                type: releaseList[index].type,
                date: releaseList[index].date,
                imageUrl: releaseList[index].imageUrl,
                openUrl: releaseList[index].openUrl,
                previewUrl: releaseList[index].previewUrl,
                /* isNew: releaseList[index].isNew, */
              ),
            );
          },
        ),
      );
    }

    return widget.errorMsg == ""
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.thisWeeksReleases.isNotEmpty) dateTitle("This week"),
                releaseList(widget.thisWeeksReleases),
                if (widget.lastWeeksReleases.isNotEmpty) dateTitle("A week ago"),
                releaseList(widget.lastWeeksReleases),
                if (widget.twoWeeksAgoReleases.isNotEmpty) dateTitle("Two weeks ago"),
                releaseList(widget.twoWeeksAgoReleases),
                if (widget.threeWeeksAgoReleases.isNotEmpty) dateTitle("Three weeks ago"),
                releaseList(widget.threeWeeksAgoReleases),
                if (widget.olderReleases.isNotEmpty) dateTitle("Over a month ago"),
                releaseList(widget.olderReleases),
              ],
            ),
          )
        : Container(
            child: Center(
              child: Text(
                widget.errorMsg,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
  }
}
