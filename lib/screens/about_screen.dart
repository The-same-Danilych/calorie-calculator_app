import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Экран "О приложении" с отображением версии и краткого описания.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Трекер калорий',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Версия: $_version'),
            const SizedBox(height: 16),
            const Text(
              'Приложение позволяет вести ежедневный учёт съеденных продуктов '
              'с автоматическим расчётом калорийности и БЖУ. Управляйте личным '
              'дневником питания, настраивайте индивидуальные нормы потребления.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}