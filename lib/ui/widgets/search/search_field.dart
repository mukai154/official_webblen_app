import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';

class SearchField extends StatelessWidget {
  final String heroTag;
  final VoidCallback onTap;
  final bool enabled;
  final TextEditingController textEditingController;
  final Function(String) onChanged;
  final Function(String) onFieldSubmitted;
  final bool autoFocus;

  SearchField({
    @required this.heroTag,
    @required this.onTap,
    @required this.enabled,
    @required this.textEditingController,
    @required this.onChanged,
    @required this.onFieldSubmitted,
    @required this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return enabled
        ? Expanded(
            child: Hero(
              tag: heroTag,
              child: Container(
                padding: EdgeInsets.only(left: 8),
                height: 35,
                decoration: BoxDecoration(
                  color: appTextFieldContainerColor(),
                  border: Border.all(
                    width: 1.0,
                    color: appBorderColorAlt(),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      child: Icon(
                        FontAwesomeIcons.search,
                        color: appFontColorAlt(),
                        size: 16,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            controller: textEditingController,
                            enabled: enabled,
                            autofocus: autoFocus == null ? true : autoFocus,
                            cursorColor: appFontColor(),
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (val) => onFieldSubmitted(val),
                            onChanged: (val) => onChanged(val),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 14),
                              hintText: "search",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Hero(
                tag: heroTag,
                child: Container(
                  padding: EdgeInsets.only(left: 8),
                  height: 35,
                  decoration: BoxDecoration(
                    color: appTextFieldContainerColor(),
                    border: Border.all(
                      width: 1.0,
                      color: appBorderColorAlt(),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        child: Icon(
                          FontAwesomeIcons.search,
                          color: appFontColorAlt(),
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: textEditingController,
                              enabled: enabled,
                              cursorColor: appFontColor(),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 14),
                                hintText: "search",
                                border: InputBorder.none,
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
          );
  }
}

class FollowerFollowingSearchField extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String) onChanged;
  final Function(String) onFieldSubmitted;
  final bool autoFocus;

  FollowerFollowingSearchField({
    @required this.textEditingController,
    @required this.onChanged,
    @required this.onFieldSubmitted,
    @required this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8),
      height: 35,
      decoration: BoxDecoration(
        color: appTextFieldContainerColor(),
        border: Border.all(
          width: 1.0,
          color: appBorderColorAlt(),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            child: Icon(
              FontAwesomeIcons.search,
              color: appFontColorAlt(),
              size: 16,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Material(
                color: Colors.transparent,
                child: TextFormField(
                  controller: textEditingController,
                  enabled: true,
                  autofocus: autoFocus == null ? true : autoFocus,
                  cursorColor: appFontColor(),
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (val) => onFieldSubmitted(val),
                  onChanged: (val) => onChanged(val),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 14),
                    hintText: "search",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
