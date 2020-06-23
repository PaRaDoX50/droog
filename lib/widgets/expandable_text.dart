import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  bool isExpanded = false;

  ExpandableText({this.text});

  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new AnimatedSize(
          vsync: this,
          duration: const Duration(milliseconds: 200),
          child: LayoutBuilder(builder: (context, constraints) {
            final span = TextSpan(text: widget.text);
            final painter = TextPainter(text: span, maxLines: 2,textDirection: TextDirection.ltr);
            painter.layout(maxWidth: constraints.maxWidth);
            if (painter.didExceedMaxLines && widget.isExpanded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.text),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.isExpanded = !widget.isExpanded;
                      });
                    },
                    child: Text("Show less"),
                  ),
                ],
              );
            } else if (painter.didExceedMaxLines && !widget.isExpanded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.text,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.isExpanded = !widget.isExpanded;
                      });
                    },
                    child: Text("Show more",style: TextStyle(color: Colors.grey),),
                  ),
                ],
              );
            }
            return Text(
              widget.text,
              softWrap: true,
              overflow: TextOverflow.fade,
            );
          }),
        ),
//      widget.isExpanded
//          ? new ConstrainedBox(constraints: new BoxConstraints())
//          : new FlatButton(
//          child: const Text('...'),
//          onPressed: () => setState(() => widget.isExpanded = true))
      ],
    );
  }
}
