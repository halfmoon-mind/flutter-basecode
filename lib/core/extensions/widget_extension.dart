import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingOnly(
          {double top = 0,
          double bottom = 0,
          double left = 0,
          double right = 0}) =>
      Padding(
          padding: EdgeInsets.only(
              top: top, bottom: bottom, left: left, right: right),
          child: this);
  Widget paddingSymmetric({double vertical = 0, double horizontal = 0}) =>
      Padding(
          padding:
              EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
          child: this);
  Widget paddingFromLTRB(
          {double left = 0,
          double top = 0,
          double right = 0,
          double bottom = 0}) =>
      Padding(
          padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);

  Widget toSliver() => SliverToBoxAdapter(child: this);
}
