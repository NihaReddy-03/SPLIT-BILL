import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/group_member.dart';
import 'billing_options.dart';

class GroupScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const GroupScreen({Key? key, required this.userEmail, required this.userName}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final _memberEmailController = TextEditingController();

  late TabController _tabController;

  List<GroupMember> _members = [];
  String? _groupCode;
  bool _isLoading = false;
  String? _errorMessage;

  static const _primaryColor = Colors.blue;
  static const _successColor = Colors.green;
  static const _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _resetMembers();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _resetForm();
      }
    });
  }

  void _resetMembers() {
    _members = [
      GroupMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: widget.userName,
        email: widget.userEmail,
      )
    ];
  }

  void _resetForm() {
    setState(() {
      _errorMessage = null;
      _groupCode = null;
      _resetMembers();
      _memberEmailController.clear();
      _groupNameController.clear();
      _groupCodeController.clear();
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupCodeController.dispose();
    _memberEmailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _avatarColor(String email) {
    // Generate a color based on email hash for consistent avatar colors
    final hash = email.codeUnits.fold(0, (prev, elem) => prev + elem);
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.cyan.shade400,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isCreatingGroup = _tabController.index == 0;
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
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDarkMode ? Colors.white : Colors.black,
                  unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
                  indicatorColor: isDarkMode ? Colors.white : Colors.black,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Create Group'),
                    Tab(text: 'Join Group'),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          key: ValueKey<int>(_tabController.index),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Form(
                                key: _formKey,
                                child: isCreatingGroup ? _buildCreateGroupForm(isDarkMode) : _buildJoinGroupForm(isDarkMode),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.openSans(
                                    color: _errorColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              if (_groupCode != null || !isCreatingGroup) ...[
                                const SizedBox(height: 20),
                                _buildMembersCard(isCreatingGroup, isDarkMode),
                              ],
                              if ((_groupCode != null || !isCreatingGroup) && _members.length >= 2) ...[
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _confirmProceedToBilling,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _successColor.shade600,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Proceed to Billing',
                                    style: GoogleFonts.openSans(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGroupForm(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Your Group',
              style: GoogleFonts.openSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by giving your group a name. You can add members after creating it.',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Icon(
                Icons.group_add,
                size: 80,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),

        Tooltip(
          message: 'Enter a unique name for your group',
          child: TextFormField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
              prefixIcon: const Icon(Icons.group),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a group name';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _createGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor.shade600,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          child: Text(
            'Create Group',
            style: GoogleFonts.openSans(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        if (_groupCode != null) ...[
          const SizedBox(height: 20),
          _buildGroupCodeDisplay(),
        ],
      ],
    );
  }

  Widget _buildJoinGroupForm(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join an Existing Group',
              style: GoogleFonts.openSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the group code you received to join the group.',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Icon(
                Icons.vpn_key,
                size: 80,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),

        Tooltip(
          message: 'Enter the group code provided by the group admin',
          child: TextFormField(
            controller: _groupCodeController,
            decoration: InputDecoration(
              labelText: 'Group Code',
              prefixIcon: const Icon(Icons.vpn_key),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the group code';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _joinGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor.shade600,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          child: Text(
            'Join Group',
            style: GoogleFonts.openSans(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _successColor.shade50,
        border: Border.all(color: _successColor.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              _groupCode!,
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _successColor.shade800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy Group Code',
            icon: Icon(Icons.copy, color: _successColor),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _groupCode ?? ""));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group code copied to clipboard')),
              );
            },
          ),
          IconButton(
            tooltip: 'Share Group Code',
            icon: Icon(Icons.share, color: _successColor),
            onPressed: () {
              Share.share('Join my group using this code: ${_groupCode ?? ""}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMembersCard(bool isCreatingGroup, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Members',
              style: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                final isCurrentUser  = member.email == widget.userEmail;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _avatarColor(member.email),
                    child: Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    member.name,
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    member.email,
                    style: GoogleFonts.openSans(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  trailing: isCurrentUser 
                      ? Chip(
                          label: Text('You', style: GoogleFonts.openSans(fontSize: 12)),
                          backgroundColor: _successColor.shade100,
                        )
                      : IconButton(
                          tooltip: 'Remove member',
                          icon: Icon(Icons.delete_outline, color: _errorColor),
                          onPressed: () => _confirmRemoveMember(member),
                        ),
                );
              },
            ),
            if (isCreatingGroup && _groupCode != null) ...[
              const Divider(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Enter the email address of the member to add',
                      child: TextFormField(
                        controller: _memberEmailController,
                        decoration: InputDecoration(
                          labelText: 'Add member by email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !_isValidEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _addMember(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addMember,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Text(
                      'Add',
                      style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMember(GroupMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Member', style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to remove ${member.name} from the group?', style: GoogleFonts.openSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.openSans()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _members.removeWhere((m) => m.id == member.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member.name} removed from the group'), backgroundColor: _errorColor),
              );
            },
            child: Text('Remove', style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _groupCode = _generateGroupCode();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create group. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
           _errorMessage = null;
    });

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Here you can implement real verification of the group code.
      // For now, just accept any non-empty code
      setState(() {
        _groupCode = _groupCodeController.text.trim();
        // Add current user if not already in members
        if (!_members.any((m) => m.email == widget.userEmail)) {
          _members.add(GroupMember(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: widget.userName,
            email: widget.userEmail,
          ));
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined group successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to join group. Please check the code.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMember() {
    final email = _memberEmailController.text.trim();
    if (email.isEmpty) return;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_members.any((m) => m.email == email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member already added'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _members.add(GroupMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@')[0],
        email: email,
      ));
      _memberEmailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$email added to the group'), backgroundColor: Colors.green),
    );
  }

 void _confirmProceedToBilling() {
  if (_members.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add at least one more member to proceed'), backgroundColor: Colors.orange),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BillingOptionsScreen(
        groupCode: _groupCode!,
        groupMembers: _members,
        userEmail: widget.userEmail,   // <-- REQUIRED
        userName: widget.userName,     // <-- REQUIRED
      ),
    ),
  );
}


  String _generateGroupCode({int length = 6}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
