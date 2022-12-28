import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class UpgradeAllCommand extends Command<int> {
  UpgradeAllCommand({
    required Logger logger,
  }) : _logger = logger;

  @override
  String get name => 'upgrade-all';

  @override
  String get description => 'Upgrade all VSCode extensions';

  final Logger _logger;

  @override
  Future<int> run() async {
    _logger.info('Upgrade all VSCode extensions');
    // Execute the 'vscode --list-extensions' command for obtaining the list of
    // installed extensions.
    final listExtensionsResult = await Process.run(
      'code',
      ['--list-extensions'],
      runInShell: true,
    );
    if (listExtensionsResult.exitCode != 0) {
      _logger.err('Error while executing the "code --list-extensions" command');
      return listExtensionsResult.exitCode;
    }
    final installedExtensions = listExtensionsResult.stdout
        .toString()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList();
    // Execute the 'vscode --install-extension' command for each extension with
    // the '--force' option for upgrading the extension.
    for (final extension in installedExtensions) {
      _logger.info('Upgrading $extension ...');
      final installExtensionResult = await Process.run(
        'code',
        ['--install-extension', extension, '--force'],
        runInShell: true,
      );
      if (installExtensionResult.exitCode != 0) {
        _logger.err(
          'Error while executing the '
          '"code --install-extension $extension --force" command',
        );
        return installExtensionResult.exitCode;
      }
    }
    return ExitCode.success.code;
  }
}
