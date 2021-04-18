// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SongsList extends StatefulWidget {
  final List thisWeeksReleases;
  final List lastWeeksReleases;
  final List twoWeeksAgoReleases;
  final List threeWeeksAgoReleases;
  final List olderReleases;
  final String errorMsg;

  SongsList({
    this.errorMsg,
    this.thisWeeksReleases,
    this.lastWeeksReleases,
    this.twoWeeksAgoReleases,
    this.threeWeeksAgoReleases,
    this.olderReleases,
  });

  @override
  _SongsListState createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  Widget songWidget(
      {String name,
      String artists,
      String id,
      String type,
      DateTime date,
      String imageUrl,
      String openUrl}) {
    var dateFormatterNoYear = DateFormat('EEEEEEEEE, d MMMM');
    //var dateFormatterYear = DateFormat('EEEEEEEEE, d MMMM yyyy');
    String formattedDate = "";

    formattedDate = dateFormatterNoYear.format(date);
    // This was used when I had older songs
    /* if (date.year == DateTime.now().year) {
      formattedDate = dateFormatterNoYear.format(date);
    } else {
      formattedDate = dateFormatterYear.format(date);
    } */

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () async {
        /*await canLaunch(openUrl)
            ? */
        await launch(
                openUrl) /*
            : throw 'Could not launch $openUrl'*/
            ;
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            imageUrl != null
                ? Container(
                    height: 60,
                    width: 60,
                    child: Image.network(
                      imageUrl,
                      cacheHeight: 240,
                      cacheWidth: 240,
                    ),
                  )
                : Container(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(),
                  ),
            SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    artists,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      if (date.isAfter(DateTime.now()))
                        Text(
                          "Tomorrow",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
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

    Widget songList(List songList) {
      return Column(
        children: List.generate(
          songList.length,
          (index) {
            return songWidget(
              name: songList[index]["name"],
              artists: songList[index]["artists"],
              id: songList[index]["id"],
              type: songList[index]["type"],
              date: songList[index]["date"],
              imageUrl: songList[index]["imageUrl"],
              openUrl: songList[index]["openUrl"],
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
                songList(widget.thisWeeksReleases),
                if (widget.lastWeeksReleases.isNotEmpty)
                  dateTitle("A week ago"),
                songList(widget.lastWeeksReleases),
                if (widget.twoWeeksAgoReleases.isNotEmpty)
                  dateTitle("Two weeks ago"),
                songList(widget.twoWeeksAgoReleases),
                if (widget.threeWeeksAgoReleases.isNotEmpty)
                  dateTitle("Three weeks ago"),
                songList(widget.threeWeeksAgoReleases),
                if (widget.olderReleases.isNotEmpty)
                  dateTitle("Over a month ago"),
                songList(widget.olderReleases),
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
