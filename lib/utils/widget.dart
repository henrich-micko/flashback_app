import 'package:flutter/material.dart';


FutureBuilder<T> getFutureBuilder<T>(Future<T> future, Widget Function(T data) builder, {Widget? defaultChild}) {
  return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) return builder(snapshot.data as T);
        return defaultChild ?? Container();
      });
}

Widget buildSectionHeader(String title, List<Widget>? actions) {
  return AppBar(
      forceMaterialTransparency: true,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0.0,
      title: Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w300)),
      titleSpacing: 15,
      actions: actions
  );
}

enum JoinAlign {
  horizontal,
  vertical
}

List<Widget> join<T extends Widget>(Widget joinTo, List<T> children, [JoinAlign align=JoinAlign.horizontal]) {
  return children.map(
          (item) => align == JoinAlign.horizontal ? Row(children: [item, joinTo]) : Column(children: [item, joinTo])
  ).toList();
}