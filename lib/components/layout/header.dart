import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Image(
                //   image: AssetImage('assets/images/logo.jpg'),
                //   height: 12,
                // ),
                Image(
                  // alignment: AlignmentGeometry.topCenter,
                  // fit: BoxFit.cover,
                  //  width: 1,
                  //   height: 1,
                  image: AssetImage(
                    'assets/images/logo.jpg',
                  ),
                ),

                Text(
                  'Relief',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(
                  'Flow',
                  style: TextStyle(
                    color: const Color.fromARGB(
                      255,
                      4,
                      212,
                      245,
                    ).withOpacity(1.0),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.notifications_active),
                  onPressed: () {
                    // ...
                  },
                ),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    // ...
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}
