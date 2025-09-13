import 'package:flutter/material.dart';
import '../models/group_member.dart';
import 'bill_summary.dart';

class TripBillingScreen extends StatefulWidget {
  final List<GroupMember> groupMembers;
  final String groupCode;

  TripBillingScreen({
    required this.groupMembers,
    required this.groupCode,
  });

  @override
  _TripBillingScreenState createState() => _TripBillingScreenState();
}

class _TripBillingScreenState extends State<TripBillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transportationController = TextEditingController();
  final _accommodationController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _miscController = TextEditingController();
  
  Map<String, bool> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    // Initialize all members as selected
    for (var member in widget.groupMembers) {
      _selectedMembers[member.id] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Billing'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Expenses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildExpenseField(
                        controller: _transportationController,
                        label: 'Transportation',
                        icon: Icons.directions_car,
                        hint: 'Flights, gas, taxi, etc.',
                      ),
                      SizedBox(height: 15),
                      _buildExpenseField(
                        controller: _accommodationController,
                        label: 'Accommodation',
                        icon: Icons.hotel,
                        hint: 'Hotels, Airbnb, etc.',
                      ),
                      SizedBox(height: 15),
                      _buildExpenseField(
                        controller: _activitiesController,
                        label: 'Activities',
                        icon: Icons.local_activity,
                        hint: 'Tours, tickets, etc.',
                      ),
                      SizedBox(height: 15),
                      _buildExpenseField(
                        controller: _miscController,
                        label: 'Miscellaneous',
                        icon: Icons.more_horiz,
                        hint: 'Other expenses',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Split Among',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      ...widget.groupMembers.map((member) => CheckboxListTile(
                        title: Text(member.name),
                        subtitle: Text(member.email),
                        value: _selectedMembers[member.id],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedMembers[member.id] = value ?? false;
                          });
                        },
                        activeColor: Colors.blue.shade600,
                      )).toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculateSplit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Calculate Split',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: '\$ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'Please enter a valid amount';
          }
          if (double.parse(value) < 0) {
            return 'Amount cannot be negative';
          }
        }
        return null;
      },
    );
  }

  void _calculateSplit() {
    if (_formKey.currentState!.validate()) {
      double transportation = double.tryParse(_transportationController.text) ?? 0;
      double accommodation = double.tryParse(_accommodationController.text) ?? 0;
      double activities = double.tryParse(_activitiesController.text) ?? 0;
      double misc = double.tryParse(_miscController.text) ?? 0;

      double totalAmount = transportation + accommodation + activities + misc;

      if (totalAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter at least one expense amount'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      List<GroupMember> selectedMembers = widget.groupMembers
          .where((member) => _selectedMembers[member.id] == true)
          .toList();

      if (selectedMembers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one member'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Map<String, double> splitAmounts = {};
      double perPersonAmount = totalAmount / selectedMembers.length;

      for (var member in selectedMembers) {
        splitAmounts[member.name] = perPersonAmount;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillSummaryScreen(
            billType: 'Trip',
            totalAmount: totalAmount,
            splitAmounts: splitAmounts,
            groupMembers: widget.groupMembers,
            groupCode: widget.groupCode,
            billDetails: {
              'Transportation': transportation,
              'Accommodation': accommodation,
              'Activities': activities,
              'Miscellaneous': misc,
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _transportationController.dispose();
    _accommodationController.dispose();
    _activitiesController.dispose();
    _miscController.dispose();
    super.dispose();
  }
}
