import 'package:flutter/material.dart';
import '../models/group_member.dart';
import 'trip_billing.dart';
import 'lodging_billing.dart';
import 'dining_billing.dart';
import 'group_screen.dart';

class BillingOptionsScreen extends StatelessWidget {
  final List<GroupMember> groupMembers;
  final String groupCode;
  final String userEmail;
  final String userName;

  const BillingOptionsScreen({
    Key? key,
    required this.groupMembers,
    required this.groupCode,
    required this.userEmail,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [Colors.blue.shade400, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button + Header
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupScreen(
                              userEmail: userEmail, // Pass the required parameter
                              userName: userName,   // Pass the required parameter
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Billing Options',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a billing type to split expenses among group members.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Icon(
                    Icons.payment,
                    size: 80,
                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade400,
                  ),
                ),
                const SizedBox(height: 30),
                // Billing cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: width > 800 ? 3 : 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: width > 800 ? 1 : 2.5,
                    children: [
                      _buildBillingCard(
                        context,
                        title: 'Trip Billing',
                        description: 'Split transportation, activities, and misc expenses',
                        icon: Icons.flight_takeoff,
                        color: Colors.blue.shade600,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripBillingScreen(
                              groupMembers: groupMembers,
                              groupCode: groupCode,
                            ),
                          ),
                        ),
                      ),
                      _buildBillingCard(
                        context,
                        title: 'Lodging',
                        description: 'Split hotel, Airbnb, or accommodation costs',
                        icon: Icons.hotel,
                        color: Colors.blue.shade500,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LodgingBillingScreen(
                              groupMembers: groupMembers,
                              groupCode: groupCode,
                            ),
                          ),
                        ),
                      ),
                      _buildBillingCard(
                        context,
                        title: 'Dining',
                        description: 'Split restaurant bills and food expenses',
                        icon: Icons.restaurant,
                        color: Colors.blue.shade400,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiningBillingScreen(
                              groupMembers: groupMembers,
                              groupCode: groupCode,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
