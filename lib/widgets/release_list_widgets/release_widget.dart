// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprelease/models/release.dart';
import 'package:url_launcher/url_launcher.dart';

// Theme
import 'package:sprelease/app_theme.dart';

// Widgets
import './play_button.dart';

class ReleaseWidget extends StatefulWidget {
  final Release release;

  ReleaseWidget(this.release);

  @override
  _ReleaseWidgetState createState() => _ReleaseWidgetState();
}

class _ReleaseWidgetState extends State<ReleaseWidget> {
  var _dateFormatterNoYear = DateFormat('EEEEEEEEE, d MMMM');
  Color _backgroundColor = Colors.grey[900];

  Widget _text(String text, FontWeight fontWeight, double fontSize) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppTheme.textColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String _formattedDate = _dateFormatterNoYear.format(widget.release.date);

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () async {
        /*await canLaunch(openUrl)
            ? */
        await launch(widget.release.openUrl) /*
            : throw 'Could not launch $openUrl'*/
            ;
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            widget.release.imageUrl != null
                ? Container(
                    height: 60,
                    width: 60,
                    child: Image.network(
                      widget.release.imageUrl,
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
                  _text(widget.release.name, FontWeight.bold, 16),
                  _text(widget.release.artists, FontWeight.normal, 13),
                  _text(_formattedDate, FontWeight.normal, 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.release.type,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textColor,
                        ),
                      ),
                      if (widget.release.date.isAfter(DateTime.now()))
                        Text(
                          "Tomorrow",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      /**
                       * if (isNew)
                        Text(
                          "New",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                       */
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            if (widget.release.previewUrl != "")
              PlayButton(
                trackId: widget.release.id,
                previewUrl: widget.release.previewUrl,
              ),
          ],
        ),
      ),
    );
  }
}
