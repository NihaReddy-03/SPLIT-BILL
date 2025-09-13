import 'package:flutter/material.dart';
import '../models/group_member.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String billType;
  final double totalAmount;
  final Map<String, double> splitAmounts;
  final List<GroupMember> groupMembers;
  final String groupCode;

  PaymentStatusScreen({
    required this.billType,
    required this.totalAmount,
    required this.splitAmounts,
    required this.groupMembers,
    required this.groupCode,
  });

  @override
  _PaymentStatusScreenState createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  Map<String, bool> _paymentStatus = {};
  Map<String, DateTime?> _paymentDates = {};

  @override
  void initState() {
    super.initState();
    // Initialize payment status for all members with amounts > 0
    for (var entry in widget.splitAmounts.entries) {
      if (entry.value > 0) {
        _paymentStatus[entry.key] = false;
        _paymentDates[entry.key] = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPaid = _calculateTotalPaid();
    double remainingAmount = widget.totalAmount - totalPaid;
    int paidCount = _paymentStatus.values.where((paid) => paid).length;
    int totalCount = _paymentStatus.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Status'),
        backgroundColor: _getBillTypeColor(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshStatus,
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
                    Text(
                      'Payment Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getBillTypeColor(),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusCard(
                          'Total Bill',
                          '\$${widget.totalAmount.toStringAsFixed(2)}',
                          Colors.blue,
                        ),
                        _buildStatusCard(
                          'Paid',
                          '\$${totalPaid.toStringAsFixed(2)}',
                          Colors.green,
                        ),
                        _buildStatusCard(
                          'Remaining',
                          '\$${remainingAmount.toStringAsFixed(2)}',
                          Colors.orange,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: totalPaid / widget.totalAmount,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$paidCount of $totalCount members paid',
                      style: TextStyle(
                        fontSize: 14,
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
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    ...widget.splitAmounts.entries.where((entry) => entry.value > 0).map((entry) {
                      bool isPaid = _paymentStatus[entry.key] ?? false;
                      DateTime? paymentDate = _paymentDates[entry.key];
                      
                      return Card(
                        color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPaid ? Colors.green : Colors.red,
                            child: Icon(
                              isPaid ? Icons.check : Icons.pending,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            entry.key,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount: \$${entry.value.toStringAsFixed(2)}'),
                              if (isPaid && paymentDate != null)
                                Text(
                                  'Paid on: ${_formatDate(paymentDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Switch(
                            value: isPaid,
                            onChanged: (value) => _updatePaymentStatus(entry.key, value),
                            activeColor: Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (remainingAmount <= 0) ...[
              Card(
                elevation: 4,
                color: Colors.green.shade100,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 50,
                        color: Colors.green.shade600,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'All Payments Complete!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Everyone has paid their share of the bill.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                elevation: 4,
                color: Colors.orange.shade100,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 40,
                        color: Colors.orange.shade600,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Pending Payments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Still waiting for \$${remainingAmount.toStringAsFixed(2)} from ${totalCount - paidCount} member(s)',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendReminder,
                    icon: Icon(Icons.notifications),
                    label: Text('Send Reminder'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.orange),
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportSummary,
                    icon: Icon(Icons.download),
                    label: Text('Export Summary'),
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

  Widget _buildStatusCard(String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 5),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  double _calculateTotalPaid() {
    double total = 0;
    for (var entry in widget.splitAmounts.entries) {
      if (_paymentStatus[entry.key] == true) {
        total += entry.value;
      }
    }
    return total;
  }

  void _updatePaymentStatus(String memberName, bool isPaid) {
    setState(() {
      _paymentStatus[memberName] = isPaid;
      if (isPaid) {
        _paymentDates[memberName] = DateTime.now();
      } else {
        _paymentDates[memberName] = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPaid 
            ? '$memberName marked as paid'
            : '$memberName marked as unpaid',
        ),
        backgroundColor: isPaid ? Colors.green : Colors.orange,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _refreshStatus() {
    // Simulate refreshing payment status from server
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment status refreshed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _sendReminder() {
    List<String> unpaidMembers = _paymentStatus.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    if (unpaidMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All payments are complete!'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Reminder'),
        content: Text(
          'Send payment reminder to:\n\n${unpaidMembers.join('\n')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reminders sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _exportSummary() {
    String summary = '''
Payment Summary - ${widget.billType} Bill
Group: ${widget.groupCode}
Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}

Payment Status:
${widget.splitAmounts.entries.where((e) => e.value > 0).map((entry) {
  bool isPaid = _paymentStatus[entry.key] ?? false;
  String status = isPaid ? '✅ PAID' : '❌ PENDING';
  DateTime? paymentDate = _paymentDates[entry.key];
  String dateStr = paymentDate != null ? ' (${_formatDate(paymentDate)})' : '';
  return '${entry.key}: \$${entry.value.toStringAsFixed(2)} - $status$dateStr';
}).join('\n')}

Total Paid: \$${_calculateTotalPaid().toStringAsFixed(2)}
Remaining: \$${(widget.totalAmount - _calculateTotalPaid()).toStringAsFixed(2)}

Generated on: ${_formatDate(DateTime.now())}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Summary'),
        content: SingleChildScrollView(
          child: Text(summary),
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
                  content: Text('Summary copied to clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Copy'),
          ),
        ],
      ),
    );
  }

  Color _getBillTypeColor() {
    switch (widget.billType.toLowerCase()) {
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
}