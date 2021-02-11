enum CommandOption {
  help,
  kbytes,
  mbytes,
  expand,
  sortedAscending,
  sortedDescending,
  sortedAlfabetic,
}

final optionsMap = {
  '-h': CommandOption.help,
  '--help': CommandOption.help,
  '-k': CommandOption.kbytes,
  '--kbytes': CommandOption.kbytes,
  '-m': CommandOption.mbytes,
  '--mbytes': CommandOption.mbytes,
  '--expand': CommandOption.expand,
  '-x': CommandOption.expand,
  '-s': CommandOption.sortedAscending,
  '--sortedAscending': CommandOption.sortedAscending,
  '-S': CommandOption.sortedDescending,
  '--sortedDescending': CommandOption.sortedDescending,
  '-a': CommandOption.sortedAlfabetic,
  '--sortedAlfabetic': CommandOption.sortedAlfabetic,
};

List<CommandOption> parseOptions(List<String> arguments) {
  final parsedOptions = <CommandOption>{};
  arguments.where((arg) => arg.startsWith('-')).forEach((arg) {
    var option = optionsMap[arg];
    if (option == null) {
      option = CommandOption.help;
      print('Invalid option "$arg"');
    }
    parsedOptions.add(option);
  });

  return parsedOptions.toList(growable: false);
}
