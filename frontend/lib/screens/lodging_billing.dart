import 'package:flutter/material.dart';
import '../models/group_member.dart';
import 'bill_summary.dart';

class LodgingBillingScreen extends StatefulWidget {
  final List<GroupMember> groupMembers;
  final String groupCode;

  LodgingBillingScreen({
    required this.groupMembers,
    required this.groupCode,
  });

  @override
  _LodgingBillingScreenState createState() => _LodgingBillingScreenState();
}

class _LodgingBillingScreenState extends State<LodgingBillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _nightsController = TextEditingController();
  final _taxesController = TextEditingController();
  final _cleaningController = TextEditingController();
  
  Map<String, bool> _selectedMembers = {};
  String _selectedLodgingType = 'Hotel';
  final List<String> _lodgingTypes = ['Hotel', 'Airbnb', 'Hostel', 'Resort', 'Other'];

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
        title: Text('Lodging Billing'),
        backgroundColor: Colors.green.shade600,
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
                        'Lodging Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedLodgingType,
                        decoration: InputDecoration(
                          labelText: 'Lodging Type',
                          prefixIcon: Icon(Icons.hotel),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _lodgingTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLodgingType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _totalAmountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Base Amount',
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the base amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _nightsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Number of Nights',
                          prefixIcon: Icon(Icons.nights_stay),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (int.parse(value) <= 0) {
                              return 'Nights must be greater than 0';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _taxesController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Taxes & Fees',
                          prefixIcon: Icon(Icons.receipt),
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
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _cleaningController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cleaning Fee',
                          prefixIcon: Icon(Icons.cleaning_services),
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
                        activeColor: Colors.green.shade600,
                      )).toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Calculation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Base Amount + Taxes & Fees + Cleaning Fee',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _calculatePreview(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
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
                        backgroundColor: Colors.green.shade600,
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

  String _calculatePreview() {
    double base = double.tryParse(_totalAmountController.text) ?? 0;
    double taxes = double.tryParse(_taxesController.text) ?? 0;
    double cleaning = double.tryParse(_cleaningController.text) ?? 0;
    double total = base + taxes + cleaning;
    
    int selectedCount = _selectedMembers.values.where((selected) => selected).length;
    
    if (total > 0 && selectedCount > 0) {
      double perPerson = total / selectedCount;
      return 'Total: \${total.toStringAsFixed(2)} ÷ $selectedCount = \${perPerson.toStringAsFixed(2)} per person';
    }
    return 'Enter amounts to see preview';
  }

  void _calculateSplit() {
    if (_formKey.currentState!.validate()) {
      double baseAmount = double.parse(_totalAmountController.text);
      double taxes = double.tryParse(_taxesController.text) ?? 0;
      double cleaning = double.tryParse(_cleaningController.text) ?? 0;
      double totalAmount = baseAmount + taxes + cleaning;

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

      Map<String, dynamic> billDetails = {
        'Lodging Type': _selectedLodgingType,
        'Base Amount': baseAmount,
        'Taxes & Fees': taxes,
        'Cleaning Fee': cleaning,
      };

      if (_nightsController.text.isNotEmpty) {
        billDetails['Number of Nights'] = int.parse(_nightsController.text);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillSummaryScreen(
            billType: 'Lodging',
            totalAmount: totalAmount,
            splitAmounts: splitAmounts,
            groupMembers: widget.groupMembers,
            groupCode: widget.groupCode,
            billDetails: billDetails,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _nightsController.dispose();
    _taxesController.dispose();
    _cleaningController.dispose();
    super.dispose();
  }
}
