import 'dart:io';

import 'package:intl/intl.dart';

import 'command_option.dart';

enum Unit { bytes, kbytes, mbytes }

Future<void> du(String path, {List<CommandOption> options = const []}) async {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    print('Directory "$path" does not exists.');
    return;
  }
  final duCalc = _DuCalc(dir, options);
  await duCalc.calculate();
  duCalc.printResults();
}

class _DuCalc {
  _DuCalc(this.rootDir, this.options) {
    unit = _unit(options);
  }

  final Directory rootDir;
  final List<CommandOption> options;
  late final Unit unit;
  List<_DuResult> resultsWithTotal = [];

  Unit _unit(List<CommandOption> options) {
    if (options.contains(CommandOption.mbytes)) {
      return Unit.mbytes;
    }
    if (options.contains(CommandOption.kbytes)) {
      return Unit.kbytes;
    }
    return Unit.bytes;
  }

  Future calculate() async {
    resultsWithTotal = <_DuResult>[];
    if (!options.contains(CommandOption.expand)) {
      resultsWithTotal.add(await _duResult(rootDir));
    } else {
      var total = 0.0;
      var rootTotal = 0.0;
      final dirList = rootDir.list(followLinks: false);
      await for (FileSystemEntity entry in dirList) {
        if (entry is File) {
          rootTotal += await entry.length();
        } else if (entry is Directory) {
          final result = await _duResult(entry);
          total += result.total;
          resultsWithTotal.add(result);
        }
      }
      resultsWithTotal.add(_DuResult(rootTotal, rootDir.toString(), unit));
      resultsWithTotal.add(_DuResult(total + rootTotal, 'Total', unit));
    }
  }

  Future<_DuResult> _duResult(Directory dir) async {
    final total = await _du(dir);
    return _DuResult(total, dir.toString(), unit);
  }

  Future<double> _du(Directory dir) async {
    var total = 0.0;
    final Stream<FileSystemEntity> dirList;
    try {
      dirList = dir.list(followLinks: false);
    } on FileSystemException catch (e) {
      print(e);
      return 0.0;
    }
    await for (FileSystemEntity entry in dirList) {
      try {
        if (entry is File) {
          total += await entry.length();
        } else if (entry is Directory) {
          total += await _du(entry);
        }
      } on FileSystemException catch (e) {
        print(e);
        continue;
      }
    }
    return total;
  }

  void printResults() {
    _sortResultsWithTotal();
    _printResults();
  }

  void _sortResultsWithTotal() {
    if (resultsWithTotal.length < 3) {
      return;
    }
    final total = resultsWithTotal.removeLast();
    if (options.contains(CommandOption.sortedAscending)) {
      resultsWithTotal.sort((a, b) => a.total.compareTo(b.total));
    } else if (options.contains(CommandOption.sortedDescending)) {
      resultsWithTotal.sort((a, b) => b.total.compareTo(a.total));
    } else {
      resultsWithTotal.sort((a, b) => a.description.compareTo(b.description));
    }
    resultsWithTotal.add(total);
  }

  void _printResults() {
    if (resultsWithTotal.isEmpty) {
      print('No results for $rootDir');
      return;
    }
    final totalPrintLength = resultsWithTotal.last.totalPrintLength;
    resultsWithTotal.forEach((res) => print(res.printString(length: totalPrintLength)));
  }
}

class _DuResult {
  const _DuResult(this.total, this.description, this.unit);

  static final bytesFormat = NumberFormat('#,###');
  static final generalFormat = NumberFormat('#,###.00');

  final double total;
  final String description;
  final Unit unit;

  int get totalPrintLength => _totalString().length;
  String printString({int? length}) => '${_totalString(length: length)} ${_unitString} in $description';

  String _totalString({int? length}) {
    final format = _isBytes ? bytesFormat : generalFormat;
    final double value;
    if (unit == Unit.mbytes) {
      value = total / 1024 / 1024;
    } else if (unit == Unit.kbytes) {
      value = total / 1024;
    } else {
      value = total;
    }
    final string = format.format(value);
    if (length != null) {
      return string.padLeft(length);
    }
    return string;
  }

  bool get _isBytes => unit == Unit.bytes;

  String get _unitString {
    if (unit == Unit.bytes) {
      return 'bytes';
    }
    if (unit == Unit.kbytes) {
      return 'Kb';
    }
    if (unit == Unit.mbytes) {
      return 'Mb';
    }
    return '';
  }
}
