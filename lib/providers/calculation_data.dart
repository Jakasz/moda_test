import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class CalculationData extends ChangeNotifier {
  bool isRunning = false;
  int count = 0;
  double sum = 0;
  double avg = 0;
  // ignore: non_constant_identifier_names
  double M2 = 0;
  Map<int, int> storedData = {};
  int moda = 0;
  int modaFrequency = 0;
  int timeMs = 0;
  final stopwatch = Stopwatch();

  final _minHeap = PriorityQueue<int>((a, b) => a.compareTo(b));
  final _maxHeap = PriorityQueue<int>((a, b) => b.compareTo(a));

  late StreamSubscription<dynamic> stream;

  void addIncomingValue(int value) {
    count++;
    sum += value;

    double delta = value - avg;
    avg += delta / count;
    M2 += delta * (value - avg);

    storedData[value] = (storedData[value] ?? 0) + 1;
    if (storedData[value]! > modaFrequency) {
      moda = value;
      modaFrequency = storedData[value]!;
    }
    fillMedianData(value);
  }

  void notifyAll() {
    notifyListeners();
  }

  //я знаю що це 2 рази виконується) тут тульки щоб порахувати
  //в загальному це були б 4 змінні які б тут обраховувалися і використовувалися
  //далі в гетерах
  calculateValues() {
    stopwatch.reset();
    stopwatch.start();
    getAverage();
    getModa;
    getStandardDeviation();
    findMedian();
    stopwatch.stop();
    timeMs += stopwatch.elapsedMilliseconds;
  }

  void clearData() {
    count = 0;
    sum = 0;
    avg = 0;
    M2 = 0;
    storedData = {};
    moda = 0;
    modaFrequency = 0;
    timeMs = 0;
    notifyListeners();
  }

  void fillMedianData(int value) {
    if (_maxHeap.isEmpty || value <= _maxHeap.first) {
      _maxHeap.add(value);
    } else {
      _minHeap.add(value);
    }

    if (_maxHeap.length > _minHeap.length + 1) {
      _minHeap.add(_maxHeap.removeFirst());
    } else if (_minHeap.length > _maxHeap.length) {
      _maxHeap.add(_minHeap.removeFirst());
    }
  }

  double findMedian() {
    if (_maxHeap.length > _minHeap.length) {
      return _maxHeap.first.toDouble();
    } else {
      return (_maxHeap.first + _minHeap.first) / 2.0;
    }
  }

  double getAverage() => sum / count;

  double getStandardDeviation() => sqrt(M2 / count);

  int getModa() => moda;
}
