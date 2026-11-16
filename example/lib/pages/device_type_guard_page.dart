import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class DeviceTypeGuardPage extends StatefulWidget {
  const DeviceTypeGuardPage({super.key});

  @override
  State<DeviceTypeGuardPage> createState() => _DeviceTypeGuardPageState();
}

class _DeviceTypeGuardPageState extends State<DeviceTypeGuardPage> {
  DeviceType? _simulatedDevice;

  @override
  Widget build(BuildContext context) {
    final activeTypes = GuardUtils.currentDeviceTypes(context);
    final primaryType = GuardUtils.currentDeviceType(context);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(title: const Text('📱 DeviceTypeGuard Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected Device Info',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Screen width: ${width.toStringAsFixed(1)} dp'),
                    Text('Primary type: ${primaryType.name}'),
                    Text(
                      'Active types: ${activeTypes.map((t) => t.name).join(', ')}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulation Override',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Auto-detect'),
                          selected: _simulatedDevice == null,
                          onSelected: (_) {
                            setState(() => _simulatedDevice = null);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Force Mobile'),
                          selected: _simulatedDevice == DeviceType.mobile,
                          onSelected: (_) {
                            setState(() => _simulatedDevice = DeviceType.mobile);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Force Tablet'),
                          selected: _simulatedDevice == DeviceType.tablet,
                          onSelected: (_) {
                            setState(() => _simulatedDevice = DeviceType.tablet);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Force Desktop'),
                          selected: _simulatedDevice == DeviceType.desktop,
                          onSelected: (_) {
                            setState(() => _simulatedDevice = DeviceType.desktop);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Guard Example: allowedDevices: [\'mobile\', \'tablet\']',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DeviceTypeGuard(
              allowedDevices: const ['mobile', 'tablet'],
              currentDevice: _simulatedDevice,
              builder: (_) => Card(
                color: Colors.green.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Access Granted: Mobile / Tablet layout is active!',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              fallbackBuilder: (_) => Card(
                color: Colors.orange.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.laptop, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fallback Active: Desktop layout is active!',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
