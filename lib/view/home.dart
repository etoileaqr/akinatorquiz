// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_data.dart';
import '../quiz_data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double radius = 40;

    Container icon(bool isChatGpt) {
      Color c = isChatGpt ? Colors.black : Colors.white;
      String img =
          isChatGpt ? 'openai-white-logomark.png' : 'openai-white-logomark.png';
      return Container(
        width: radius,
        height: radius,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/file/$img',
          fit: BoxFit.contain,
        ),
      );
    }

    ListTile _ListTile({required bool isChatGpt}) {
      return ListTile(
        leading: icon(isChatGpt),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: Column(children: [
        ListView(
          children: [
            _ListTile(isChatGpt: true),
            _ListTile(isChatGpt: false),
          ],
        ),
        IconButton(
          onPressed: () {
            String city = AppData.instance
                .cities[Random().nextInt(AppData.instance.cities.length)];
            AppData.instance.qd = QuizData(city: city);
            print('「選択しました」と答えてください。');
            print('選択した国: $city');
            setState(() {});
          },
          icon: const Icon(CupertinoIcons.add),
        ),
        TextFormField(
          controller: _controller,
        )
      ]),
    );
  }
}
