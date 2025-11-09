import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HELP"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            HelpDropdown(
              title: "CAUTION",
              content:
                  "Ensure that GPS location and Wi-Fi remain activated at all times. Obtain the QR code from the switch owner and verify that it has not expired. If the QR code has expired, please contact the owner to request a new one.",
            ),
            HelpDropdown(
              title: "How to CONNECT",
              content: "1. Select the Router icon.\n"
                  "2. Tap 'Add Router' and scan the QR code provided by the owner.\n"
                  "3. Select the Switch icon.\n"
                  "4. Tap 'Add Switch' and scan the QR code provided by the owner.\n"
                  "5. Open the Switch icon, select the desired switch, then tap the ON/OFF button to turn it on or off.\n"
                  "6. Select the Groups icon.\n"
                  "7. Tap 'Add Group' and scan the group's QR code provided by the owner.\n"
                  "8. Open the Group icon, select the specific group, then tap the ON/OFF button to control all switches in that group.",
            ),

            HelpDropdown(
              title: "Support from Manufacturer",
              content:
                  "Contact: Mr. Rajender Dandu\nPhone: +91 79969 07698\nEmail: rajender.dandu@belbirdtechnologies.com",
            ),

            // Add more HelpDropdown widgets as needed
          ],
        ),
      ),
    );
  }
}

class HelpDropdown extends StatefulWidget {
  final String title;
  final String content;

  const HelpDropdown({super.key, required this.title, required this.content});

  @override
  State<HelpDropdown> createState() => _HelpDropdownState();
}

class _HelpDropdownState extends State<HelpDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
