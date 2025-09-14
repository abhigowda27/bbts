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
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              HelpDropdown(
                title: "CAUTION",
                content:
                    "Make sure to keep the GPS location and Wi-Fi activated at all times. Obtain the QR code from the switch owner and verify that it is not expired. If the QR code has expired, please reach out to the owner for a new one.",
              ),
              HelpDropdown(
                  title: "How to CONNECT",
                  content:
                      "Kindly select the router icon and add a router using the QR code shared by the owner. Next, tap the switch icon and add a switch using the QR code provided by the owner. Once added, access the switch icon, choose the specific switch, and then tap the on/off button to either switchOn or Off it. Next, tap the groups icon and add a group using the QR code provided by the owner.Once added, access the group icon, choose the specific group, and then tap the on/off button to either On or Off to all group switches"),
              HelpDropdown(
                  title: "Support from Manufacturer",
                  content:
                      "Contact: Mr.Rajender Dandu\nPh: +91 7996907698\nMail: rajendar.dandu@belbirdtechnologies.com"),
              // Add more HelpDropdown widgets as needed
            ],
          ),
        ),
      ),
    );
  }
}

class HelpDropdown extends StatefulWidget {
  final String title;
  final String content;

  const HelpDropdown({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  State<HelpDropdown> createState() => _HelpDropdownState();
}

class _HelpDropdownState extends State<HelpDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
