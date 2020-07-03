import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {

  final TextEditingController controller;
  final Function onTextChanged;
  SearchTextField({this.onTextChanged,this.controller});


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 35,
              child: TextField(
                maxLines: null,
                controller: controller,

                style: TextStyle(color: Colors.black),
                onChanged: (_) => onTextChanged(),
                decoration: InputDecoration(

                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.only(
                    left: 16,
                  ),

//              focusedBorder: OutlineInputBorder(
//
//                borderSide: BorderSide(style: BorderStyle.solid),
//                borderRadius: BorderRadius.circular(20),
//              ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.search),
        ),
      ],
    );
  }
}
