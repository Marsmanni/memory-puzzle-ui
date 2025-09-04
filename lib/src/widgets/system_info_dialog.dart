import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';

class SystemInfoDialog extends StatelessWidget {
  final SystemInfoDto info;

  const SystemInfoDialog({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.get('systemInfo')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Database group
          const Text('Database', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Database Provider: ${info.databaseProvider}'),
          Text('Connection String: ${info.databaseConnectionString}'),
          const Divider(),

          // Server group
          const Text('Server', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('EF Core Version: ${info.efCoreVersion}'),
          Text('ASP.NET Version: ${info.aspNetVersion}'),
          Text('Server IP: ${info.serverIp}'),
          Text('Server Time: ${info.serverTime}'),
          Text('Server Version: ${info.serverVersion}'),
          Text(
            'Server Deployment Time: ${info.serverDeploymentTime != null ? info.serverDeploymentTime!.toIso8601String() : "-"}',
          ),
          Text('Server Git Version: ${info.serverGitVersion}'),
          const Divider(),

          // Client group
          const Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Client IP: ${info.clientIp}'),
          Text('Client Version: ${info.clientVersion}'),
          Text(
            'Client Deployment Time: ${info.clientDeploymentTime != null ? info.clientDeploymentTime!.toIso8601String() : "-"}',
          ),
          Text('Client Git Version: ${info.clientGitVersion}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// Usage example (like LoginDialog):
void showSystemInfoDialog(BuildContext context, SystemInfoDto info) {
  showDialog(
    context: context,
    builder: (ctx) => SystemInfoDialog(info: info),
  );
}