import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/group_member.dart';
import 'payment_status.dart';

class BillSummaryScreen extends StatelessWidget {
  final String billType;
  final double totalAmount;
  final Map<String, double> splitAmounts;
  final List<GroupMember> groupMembers;
  final String groupCode;
  final Map<String, dynamic> billDetails;

  BillSummaryScreen({
    required this.billType,
    required this.totalAmount,
    required this.splitAmounts,
    required this.groupMembers,
    required this.groupCode,
    required this.billDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Summary'),
        backgroundColor: _getBillTypeColor(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareBill(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: _getBillTypeColor().withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      _getBillTypeIcon(),
                      size: 50,
                      color: _getBillTypeColor(),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '$billType Bill',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getBillTypeColor(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Group: $groupCode',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
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
                      'Bill Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    ...billDetails.entries.map((entry) {
                      // Handle different types of bill details
                      if (entry.key == 'Items' && entry.value is List) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Items:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            ...((entry.value as List).map((item) => Padding(
                              padding: EdgeInsets.only(left: 15, bottom: 3),
                              child: Text(
                                '• ${item['name']}: \$${item['price'].toStringAsFixed(2)} (shared with ${item['sharedCount']} member(s))',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ))),
                            SizedBox(height: 5),
                          ],
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                entry.value is double 
                                    ? '\$${entry.value.toStringAsFixed(2)}'
                                    : entry.value.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
                    Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getBillTypeColor(),
                          ),
                        ),
                      ],
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
                      'Split Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    ...splitAmounts.entries.where((entry) => entry.value > 0).map((entry) {
                      GroupMember member = groupMembers.firstWhere(
                        (m) => m.name == entry.key,
                        orElse: () => GroupMember(id: '', name: entry.key, email: ''),
                      );
                      return Card(
                        color: Colors.grey.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getBillTypeColor(),
                            child: Text(
                              entry.key[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            entry.key,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(member.email),
                          trailing: Text(
                            '\$${entry.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getBillTypeColor(),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                  children: [
                    Text(
                      'Share QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data: _generateQRData(),
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Scan to view bill details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareBill(context),
                    icon: Icon(Icons.share),
                    label: Text('Share Bill'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: _getBillTypeColor()),
                      foregroundColor: _getBillTypeColor(),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPaymentStatus(context),
                    icon: Icon(Icons.payment),
                    label: Text('Payment Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getBillTypeColor(),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBillTypeColor() {
    switch (billType.toLowerCase()) {
      case 'trip':
        return Colors.blue.shade600;
      case 'lodging':
        return Colors.green.shade600;
      case 'dining':
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getBillTypeIcon() {
    switch (billType.toLowerCase()) {
      case 'trip':
        return Icons.flight_takeoff;
      case 'lodging':
        return Icons.hotel;
      case 'dining':
        return Icons.restaurant;
      default:
        return Icons.receipt;
    }
  }

  String _generateQRData() {
    return 'BillSplit|$groupCode|$billType|${totalAmount.toStringAsFixed(2)}|${DateTime.now().millisecondsSinceEpoch}';
  }

  void _shareBill(BuildContext context) {
    String shareText = '''
📝 $billType Bill Summary
Group: $groupCode
Total: \$${totalAmount.toStringAsFixed(2)}

💰 Split Breakdown:
${splitAmounts.entries.where((e) => e.value > 0).map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join('\n')}

Generated by Bill Splitter App
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Bill'),
        content: SingleChildScrollView(
          child: Text(shareText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bill details copied to clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBillTypeColor(),
            ),
            child: Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _navigateToPaymentStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentStatusScreen(
          billType: billType,
          totalAmount: totalAmount,
          splitAmounts: splitAmounts,
          groupMembers: groupMembers,
          groupCode: groupCode,
        ),
      ),
    );
  }
}