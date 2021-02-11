import 'package:du/command_option.dart';
import 'package:du/du.dart';

Future main(List<String> arguments) async {
  final options = parseOptions(arguments);
  if (options.contains(CommandOption.help)) {
    printUsage();
    return;
  }

  final pathList = arguments.where((element) => !element.startsWith('-'));
  if (pathList.length > 1) {
    printUsage();
    return;
  }
  final path = pathList.isEmpty ? '.' : pathList.first;

  await du(path, options: options);
}

void printUsage() {
  print('Usage: du <option> path\n'
      '  --help, -h   =>  show command line usage\n'
      '  --kbytes, -k =>  print usage in kilo bytes\n'
      '  --mbytes, -m =>  print usage in mega bytes\n'
      '  --sortedAscending, -s =>  sort entries in ascending size\n'
      '  --sortedDescending, -S =>  sort entries in descending size\n'
      '  --sortedAlfabetic, -a =>  sort entries alfabetic\n');
}
