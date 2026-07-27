import 'package:flutter/material.dart';
import 'package:spider_vpn/providers/auth_provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/services/api_service.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class UserModel {
  final String uuid;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String imageUrl;

  UserModel({
    required this.uuid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.imageUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }
}

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> with TickerProviderStateMixin {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _loadUsers();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://your-backend-api.com/api/users'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _users = data.map((item) => UserModel.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GalaxyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with add button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Users',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GlassButton(
                      label: 'Add User',
                      icon: Icons.person_add_rounded,
                      onPressed: _showAddUserDialog,
                    ),
                  ],
                ),
              ),
              // Users list
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
                    : _error != null
                      ? _buildError()
                      : _users.isEmpty
                        ? _buildEmptyState()
                        : _buildUsersList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(),
        backgroundColor: AppColors.neonBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add User'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load users', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            GlassButton(label: 'Retry', icon: Icons.refresh, onPressed: _loadUsers),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, color: AppColors.textSecondary, size: 64),
            const SizedBox(height: 16),
            Text('No users yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Add your first VPN user', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            GlassButton(label: 'Add User', icon: Icons.person_add, onPressed: _showAddUserDialog),
          ],
        ),
      ),
    );
  }

  ListView _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final email = user.email;
    final uuid = user.uuid;
    final fullName = user.fullName;
    final role = user.role;
    final isActive = user.isActive;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: user.imageUrl != null
                    ? [AppColors.neonBlue.withOpacity(0.5), AppColors.neonPurple.withOpacity(0.5)]
                    : [AppColors.neonGreen.withOpacity(0.5), AppColors.neonBlue.withOpacity(0.5)],
              ),
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.5)),
            ),
            child: user.imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      user.fullName?.isNotEmpty == true ? user.fullName![0].toUpperCase() : email[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? email,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  email,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (user.fullName?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.work, size: 14, color: AppColors.neonBlue.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        user.role,
                        style: TextStyle(color: AppColors.neonBlue, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.neonGreen.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? AppColors.neonGreen.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                ),
                child: Text(
                  isActive ? 'Active' : 'Disabled',
                  style: TextStyle(
                    color: isActive ? AppColors.neonGreen : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIcon(Icons.qr_code, () => _showQRCode(user), AppColors.neonBlue),
                  _buildActionIcon(Icons.edit, () => _showEditUserDialog(user), AppColors.neonPurple),
                  _buildActionIcon(Icons.content_copy, () => _copyConfigLink(user), AppColors.neonGreen),
                  _buildActionIcon(Icons.person, () => _showUserDetails(user), AppColors.neonOrange),
                  _buildActionIcon(Icons.delete, () => _confirmDeleteUser(user), AppColors.danger),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user, onSaved: () => _loadUsers()),
    );
  }

  void _showQRCode(UserModel user) {
    final qrData = _generateUserQRData(user);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('QR Code for ${user.fullName ?? user.email}', style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              const SizedBox(height: 16),
              Text('Scan to get user config', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              GlassButton(
                label: 'Copy Link',
                icon: Icons.copy,
                onPressed: () => _copyToClipboard(qrData),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateUserQRData(UserModel user) {
    final data = {
      'email': user.email,
      'uuid': user.uuid,
      'fullName': user.fullName,
      'role': user.role,
      'isActive': user.isActive,
    };
    return jsonEncode(data);
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppColors.neonGreen,
      ),
    );
  }

  void _copyConfigLink(UserModel user) {
    final configUrl = 'https://spidervpn/app/user/${user.uuid}';
    Clipboard.setData(ClipboardData(text: configUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Config link copied to clipboard'),
        backgroundColor: AppColors.neonGreen,
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.fullName ?? user.email, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDetailItem(Icons.email, 'Email', user.email),
                  _buildDetailItem(Icons.work, 'Role', user.role),
                  _buildDetailItem(Icons.toggle_on, 'Status', user.isActive ? 'Active' : 'Disabled'),
                ],
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: 'Close',
                icon: Icons.close,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neonBlue, size: 24),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://your-backend-api.com/api/users'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _users = data.map((item) => UserModel.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgDarkCard,
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete ${user.fullName ?? user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      final response = await http.delete(
        Uri.parse('http://your-backend-api.com/api/users/${user.uuid}'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _users.removeWhere((u) => u.uuid == user.uuid);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return GlassContainer(
          margin: const EdgeInsets.all(16),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add New User', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Full Name (optional)',
                  hint: 'Enter full name',
                  controller: _fullNameController,
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Email',
                  hint: 'user@spiderpanel.com',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Please enter email' : null,
                ),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Password',
                  hint: 'Min 6 characters',
                  controller: _passwordController,
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Cancel',
                        icon: Icons.cancel,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        label: 'Add User',
                        icon: Icons.add,
                        onPressed: _isLoading ? null : _submitUser,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('http://your-backend-api.com/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'fullName': _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
        }),
      );
      
      if (response.statusCode == 200) {
        final newUser = UserModel.fromJson(jsonDecode(response.body));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User added successfully'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        // Refresh user list
        _loadUsers();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class EditUserDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSaved;

  const EditUserDialog({super.key, required this.user, required this.onSaved});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _fullNameController = TextEditingController(text: widget.user.fullName ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return GlassContainer(
          margin: const EdgeInsets.all(16),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Edit User', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Email',
                  hint: 'Enter email',
                  controller: _emailController,
                  icon: Icons.email,
                  validator: (v) => v == null || !v.contains('@') ? 'Please enter valid email' : null,
                ),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Full Name',
                  hint: 'Enter full name',
                  controller: _fullNameController,
                  icon: Icons.person,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Cancel',
                        icon: Icons.cancel,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        label: 'Save Changes',
                        icon: Icons.save,
                        onPressed: _isLoading ? null : _saveUser,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.put(
        Uri.parse('http://your-backend-api.com/api/users/${widget.user.uuid}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'fullName': _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
        }),
      );
      
      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(jsonDecode(response.body));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        widget.onSaved();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Placeholder for additional screens that would be needed
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, color: AppColors.neonBlue, size: 64),
              const SizedBox(height: 16),
              Text('$title (Coming Soon)', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('This feature is under development', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}