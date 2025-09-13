import 'package:flutter/material.dart';
import '../models/group_member.dart';
import '../models/bill_item.dart';
import 'bill_summary.dart';

class DiningBillingScreen extends StatefulWidget {
  final List<GroupMember> groupMembers;
  final String groupCode;

  DiningBillingScreen({
    required this.groupMembers,
    required this.groupCode,
  });

  @override
  _DiningBillingScreenState createState() => _DiningBillingScreenState();
}

class _DiningBillingScreenState extends State<DiningBillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipController = TextEditingController();
  final _taxController = TextEditingController();
  
  List<BillItem> _billItems = [];
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  Map<String, bool> _selectedMembersForItem = {};

  @override
  void initState() {
    super.initState();
    _initializeSelectedMembers();
  }

  void _initializeSelectedMembers() {
    for (var member in widget.groupMembers) {
      _selectedMembersForItem[member.id] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dining Bill'),
        backgroundColor: Colors.orange.shade600,
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
                        'Add Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _itemNameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name',
                          prefixIcon: Icon(Icons.fastfood),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _itemPriceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Shared with:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...widget.groupMembers.map((member) => CheckboxListTile(
                        dense: true,
                        title: Text(member.name),
                        value: _selectedMembersForItem[member.id],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedMembersForItem[member.id] = value ?? false;
                          });
                        },
                        activeColor: Colors.orange.shade600,
                      )).toList(),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                        ),
                        child: Text(
                          'Add Item',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_billItems.isNotEmpty) ...[
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        ..._billItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          BillItem item = entry.value;
                          return Card(
                            color: Colors.grey.shade50,
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                '\${item.price.toStringAsFixed(2)} - Shared with ${item.sharedWith.length} member(s)',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ),
                          );
                        }).toList(),
                        Divider(),
                        Text(
                          'Subtotal: \${_calculateSubtotal().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Charges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _taxController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Tax',
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
                        controller: _tipController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Tip',
                          prefixIcon: Icon(Icons.star),
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
                      'Total Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _calculateTotal().toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 24,
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
                      onPressed: _billItems.isNotEmpty ? _calculateSplit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
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

  void _addItem() {
    if (_itemNameController.text.isNotEmpty && 
        _itemPriceController.text.isNotEmpty) {
      double price = double.tryParse(_itemPriceController.text) ?? 0;
      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid price'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      List<String> sharedWith = widget.groupMembers
          .where((member) => _selectedMembersForItem[member.id] == true)
          .map((member) => member.id)
          .toList();

      if (sharedWith.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one member for this item'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _billItems.add(BillItem(
          name: _itemNameController.text,
          price: price,
          sharedWith: sharedWith,
        ));
        _itemNameController.clear();
        _itemPriceController.clear();
        // Reset selections to all members
        _initializeSelectedMembers();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _billItems.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    return _billItems.fold(0, (sum, item) => sum + item.price);
  }

  double _calculateTotal() {
    double subtotal = _calculateSubtotal();
    double tax = double.tryParse(_taxController.text) ?? 0;
    double tip = double.tryParse(_tipController.text) ?? 0;
    return subtotal + tax + tip;
  }

  void _calculateSplit() {
    if (_formKey.currentState!.validate()) {
      if (_billItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one item'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      double tax = double.tryParse(_taxController.text) ?? 0;
      double tip = double.tryParse(_tipController.text) ?? 0;
      double totalAmount = _calculateTotal();

      // Calculate individual amounts
      Map<String, double> splitAmounts = {};
      
      // Initialize all members with 0
      for (var member in widget.groupMembers) {
        splitAmounts[member.name] = 0;
      }

      // Add item costs
      for (var item in _billItems) {
        double itemCostPerPerson = item.price / item.sharedWith.length;
        for (String memberId in item.sharedWith) {
          GroupMember member = widget.groupMembers.firstWhere((m) => m.id == memberId);
          splitAmounts[member.name] = (splitAmounts[member.name] ?? 0) + itemCostPerPerson;
        }
      }

      // Add shared tax and tip
      if (tax > 0 || tip > 0) {
        double sharedAmount = (tax + tip) / widget.groupMembers.length;
        for (var member in widget.groupMembers) {
          splitAmounts[member.name] = (splitAmounts[member.name] ?? 0) + sharedAmount;
        }
      }

      Map<String, dynamic> billDetails = {
        'Subtotal': _calculateSubtotal(),
        'Tax': tax,
        'Tip': tip,
        'Items': _billItems.map((item) => {
          'name': item.name,
          'price': item.price,
          'sharedCount': item.sharedWith.length,
        }).toList(),
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillSummaryScreen(
            billType: 'Dining',
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
    _tipController.dispose();
    _taxController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }
}
