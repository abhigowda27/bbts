import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class FanSpeedControl extends StatefulWidget {
  final Map<String, dynamic> fanStatusList;
  final Map<String, dynamic> device;
  final Function toggleSwitch;
  final int deviceType;
  final String? deviceId;

  const FanSpeedControl({
    super.key,
    required this.fanStatusList,
    required this.device,
    required this.toggleSwitch,
    required this.deviceType,
    this.deviceId,
  });

  @override
  State<FanSpeedControl> createState() => _FanSpeedControlState();
}

class _FanSpeedControlState extends State<FanSpeedControl> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    final keys = widget.fanStatusList.keys.toList();
    final currentKey = widget.device["details"]["statusTxt"]?.toString();
    int index = currentKey != null ? keys.indexOf(currentKey) : 0;

    // If not found, default to 0
    if (index < 0) index = 0;

    _currentValue = index.clamp(0, keys.length - 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final keys = widget.fanStatusList.keys.toList();

    return SleekCircularSlider(
      min: 0,
      max: (keys.length - 1).toDouble(),
      initialValue: _currentValue,
      appearance: CircularSliderAppearance(
        size: 180,
        customWidths: CustomSliderWidths(
          trackWidth: 8,
          progressBarWidth: 15,
          handlerSize: 12,
        ),
        customColors: CustomSliderColors(
          trackColor: Colors.grey,
          progressBarColors: [
            Colors.blueAccent,
            Colors.cyanAccent,
            Colors.greenAccent,
            Colors.purpleAccent,
          ],
          shadowColor: Colors.cyanAccent,
          shadowStep: 10,
          dotColor: Colors.white,
        ),
        infoProperties: InfoProperties(
          mainLabelStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Colors.purpleAccent,
                  Colors.blueAccent,
                ],
              ).createShader(
                  const Rect.fromLTWH(0, 0, 200, 70)), // gradient text
            shadows: const [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 6,
                color: Colors.black26,
              ),
            ],
          ),
          modifier: (value) {
            int index = value.round().clamp(0, keys.length - 1);

            return keys[index];
          },
        ),
        startAngle: 150,
        angleRange: 240,
        animDurationMultiplier: 1.5,
      ),
      onChangeEnd: (value) {
        int index = value.round().clamp(0, keys.length - 1);
        String level = keys[index];
        final statusId = widget.fanStatusList[level];

        widget.toggleSwitch(
          widget.deviceId,
          level,
          widget.device["uid"] ?? "",
          widget.deviceType,
        );

        setState(() {
          _currentValue = index.toDouble();
          widget.device["details"]["status"] = statusId;
          widget.device["details"]["statusTxt"] = level;
        });
      },
    );
  }
}
