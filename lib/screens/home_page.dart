import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../providers/calculation_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<CalculationData>();
    final wsUrl = Uri.parse('wss://trade.termplat.com:8800/?password=1234');
    final channel = WebSocketChannel.connect(
      wsUrl,
    );

    void connectWss() {
      try {
        dataProvider.stream = channel.stream.listen(
          (data) {
            Map<String, dynamic> parsedData = jsonDecode(data);
            final value = parsedData['value'];
            dataProvider.addIncomingValue(value);
          },
          onError: (error) {
            channel.sink.close();
          },
          onDone: () {
            channel.sink.close();
          },
        );
      } catch (e) {
        channel.sink.close();
      }
    }

    disconnectWss() {
      dataProvider.stream.cancel();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
          backgroundColor: const Color(0xFF2C2C2C),
          title: dataProvider.isRunning
              ? const Text(
                  'Web socket data processing...',
                  style: TextStyle(color: Colors.white60),
                )
              : const Text('Waiting for start',
                  style: TextStyle(color: Colors.white60))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  dataProvider.isRunning = !dataProvider.isRunning;
                  dataProvider.notifyAll();
                  dataProvider.isRunning ? connectWss() : disconnectWss();
                },
                child: dataProvider.isRunning
                    ? const Text("Stop", style: TextStyle(fontSize: 21))
                    : const Text(
                        "Start",
                        style: TextStyle(fontSize: 21),
                      )),
            const Gap(16),
            ElevatedButton(
                onPressed: () {
                  dataProvider.stream.cancel();
                  dataProvider.isRunning = false;

                  _showModal(context, dataProvider);
                },
                child:
                    const Text("Statisctics", style: TextStyle(fontSize: 21))),
          ],
        ),
      ),
    );
  }

  void onModalClosed(String result) {
    //print("Modal closed with result: $result");
  }

  Future<void> _showModal(
      BuildContext context, CalculationData dataProvider) async {
    final result = await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Statistics'),
          content: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Records = ${dataProvider.count}'),
                  Text('Avg =  ${dataProvider.getAverage()}'),
                  Text('Moda = ${dataProvider.getModa()}'),
                  Text('StdDev = ${dataProvider.getStandardDeviation()}'),
                  Text('Median = ${dataProvider.findMedian()}'),
                  Text('Time spent = ${dataProvider.timeMs}')
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                dataProvider.clearData();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    // Call the callback with the result
    if (result != null) {
      onModalClosed(result);
    }
  }
}
