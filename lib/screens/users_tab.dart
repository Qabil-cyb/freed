import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'glass_container.dart';
import 'theme_data.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiKey = await ApiService().getApiKey();
    if (apiKey == null) {
      setState(() {
        _users = List.generate(5, (index) => User.mock(index: index));
        _isLoading = false;
      });
      return;
    }

    final response = await ApiService().getUsers(apiKey);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _users = response.data!;
      } else {
        _users = List.generate(5, (index) => User.mock(index: index));
        _errorMessage = response.message;
      }
    });
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(onSave: _createUser),
    );
  }

  Future<void> _createUser(User user) async {
    setState(() => _isLoading = true);

    final apiKey = await ApiService().getApiKey();
    if (apiKey == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await ApiService().addUser(apiKey, user);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _users.add(response.data!);
      } else {
        _errorMessage = response.message;
      }
    });
  }

  void _showQrDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => QrDialog(user: user),
    );
  }

  Future<void> _deleteUser(User user) async {
    setState(() => _isLoading = true);

    final apiKey = await ApiService().getApiKey();
    if (apiKey == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await ApiService().deleteUser(apiKey, user.id);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success) {
        _users.removeWhere((u) => u.id == user.id);
      } else {
        _errorMessage = response.message;
      }
    });
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onSave: _updateUser,
      ),
    );
  }

  Future<void> _updateUser(User user) async {
    setState(() => _isLoading = true);

    final apiKey = await ApiService().getApiKey();
    if (apiKey == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await ApiService().updateUser(apiKey, user.id, user);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user;
        }
      } else {
        _errorMessage = response.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserDialog,
        backgroundColor: colors.neon,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.neon),
            )
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              color: colors.neon,
              child: _errorMessage != null
                  ? Center(
                      child: GlassContainer(
                        blur: 15,
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _users.isEmpty
                      ? Center(
                          child: GlassContainer(
                            blur: 15,
                            padding: const EdgeInsets.all(32),
                            margin: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_outline, size: 64, color: Colors.white54),
                                const SizedBox(height: 16),
                                const Text(
                                  'No users found',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add your first user to get started',
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _showCreateUserDialog,
                                  child: const Text('Add User'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserCard(user, index, colors);
                          },
                        ),
            ),
    );
  }

  Widget _buildUserCard(User user, int index, ThemeColors colors) {
    final isExpired = user.status == UserStatus.expired;
    final trafficValue = user.trafficLimit > 0 ? user.usedTraffic / user.trafficLimit : 0.0;
    final formattedExpire = '${user.expireDate.month}/${user.expireDate.day}/${user.expireDate.year}';

    return GlassContainer(
      blur: 15,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Expired', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                ],
              ),
              GestureDetector(
                onTap: () => Clipboard.setData(ClipboardData(text: user.uuid)),
                child: Row(
                  children: [
                    Text(
                      user.uuidShort,
                      style: TextStyle(color: colors.neonAccent, fontSize: 14, fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.copy, color: colors.neon, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Traffic bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.trafficDisplay,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    '${(trafficValue * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: colors.neon, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: Colors.white.withAlpha(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: trafficValue.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: trafficValue > 0.8 ? Colors.red : colors.neon,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: (trafficValue > 0.8 ? Colors.red : colors.neon).withAlpha(80),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text('Expires: $formattedExpire', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.devices, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text('IP: ${user.ipLimit}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('QR', Icons.qr_code, colors.neon, () => _showQrDialog(user)),
              _buildActionButton('EDIT', Icons.edit, colors.neonAccent, () => _showEditUserDialog(user)),
              _buildActionButton('COPY', Icons.copy, colors.neon, () => Clipboard.setData(ClipboardData(text: user.subLink))),
              _buildActionButton('DEL', Icons.delete, Colors.red, () => _deleteUser(user)),
              _buildActionButton('SUB', Icons.link, Colors.orange, () => Clipboard.setData(ClipboardData(text: user.subLink))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: index * 80)).slideX(begin: 0.1);
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class CreateUserDialog extends StatefulWidget {
  final Function(User) onSave;
  const CreateUserDialog({super.key, required this.onSave});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _trafficLimitController = TextEditingController(text: '50');
  final _daysLimitController = TextEditingController(text: '30');
  final _ipLimitController = TextEditingController(text: '2');
  List<Inbound> _inbounds = [];
  int? _selectedInboundId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInbounds();
  }

  Future<void> _loadInbounds() async {
    final apiKey = await ApiService().getApiKey();
    if (apiKey == null) {
      setState(() {
        _inbounds = List.generate(3, (index) => Inbound.mock(index: index));
      });
      return;
    }

    final response = await ApiService().getInbounds(apiKey);
    if (response.success && response.data != null) {
      setState(() => _inbounds = response.data!);
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final selectedInbound = _inbounds.firstWhere(
      (i) => i.id == _selectedInboundId.toString(),
      orElse: () => Inbound.mock(index: 0),
    );

    final user = User(
      id: _generateId(),
      uuid: _generateId(),
      username: _usernameController.text,
      email: '${_usernameController.text}@spider.local',
      inboundId: int.tryParse(_selectedInboundId?.toString() ?? '0') ?? 0,
      inboundRemark: selectedInbound.remark,
      trafficLimit: (int.tryParse(_trafficLimitController.text) ?? 50) * 1024 * 1024 * 1024,
      usedTraffic: 0,
      daysLimit: int.tryParse(_daysLimitController.text) ?? 30,
      expireDate: DateTime.now().add(const Duration(days: int.tryParse(_daysLimitController.text) ?? 30)),
      ipLimit: int.tryParse(_ipLimitController.text) ?? 2,
      status: UserStatus.active,
      subLink: 'https://panel.local/sub/${_generateId()}',
    );

    await widget.onSave(user);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        blur: 20,
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.neon,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedInboundId,
                  decoration: const InputDecoration(
                    labelText: 'Inbound',
                    prefixIcon: Icon(Icons.dns),
                  ),
                  items: _inbounds.map((inbound) {
                    return DropdownMenuItem(
                      value: int.tryParse(inbound.id),
                      child: Text(inbound.remark),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedInboundId = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _trafficLimitController,
                  decoration: const InputDecoration(
                    labelText: 'Traffic Limit (GB)',
                    prefixIcon: Icon(Icons.data_usage),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _daysLimitController,
                  decoration: const InputDecoration(
                    labelText: 'Days Limit',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipLimitController,
                  decoration: const InputDecoration(
                    labelText: 'IP Limit',
                    prefixIcon: Icon(Icons.devices),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final User user;
  final Function(User) onSave;
  const EditUserDialog({super.key, required this.user, required this.onSave});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _trafficLimitController;
  late final TextEditingController _daysLimitController;
  late final TextEditingController _ipLimitController;
  List<Inbound> _inbounds = [];
  int? _selectedInboundId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    final trafficGb = widget.user.trafficLimit / (1024 * 1024 * 1024);
    _trafficLimitController = TextEditingController(text: trafficGb.toStringAsFixed(0));
    _daysLimitController = TextEditingController(text: widget.user.daysLimit.toString());
    _ipLimitController = TextEditingController(text: widget.user.ipLimit.toString());
    _selectedInboundId = widget.user.inboundId;
    _loadInbounds();
  }

  Future<void> _loadInbounds() async {
    final apiKey = await ApiService().getApiKey();
    if (apiKey == null) {
      setState(() {
        _inbounds = List.generate(3, (index) => Inbound.mock(index: index));
      });
      return;
    }

    final response = await ApiService().getInbounds(apiKey);
    if (response.success && response.data != null) {
      setState(() => _inbounds = response.data!);
      _selectedInboundId = widget.user.inboundId;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final selectedInbound = _inbounds.firstWhere(
      (i) => i.id == _selectedInboundId.toString(),
      orElse: () => Inbound.mock(index: 0),
    );

    final updated = User(
      id: widget.user.id,
      uuid: widget.user.uuid,
      username: _usernameController.text,
      email: widget.user.email,
      inboundId: _selectedInboundId ?? widget.user.inboundId,
      inboundRemark: selectedInbound.remark,
      trafficLimit: (int.tryParse(_trafficLimitController.text) ?? 50) * 1024 * 1024 * 1024,
      usedTraffic: widget.user.usedTraffic,
      daysLimit: int.tryParse(_daysLimitController.text) ?? 30,
      expireDate: DateTime.now().add(Duration(days: int.tryParse(_daysLimitController.text) ?? 30)),
      ipLimit: int.tryParse(_ipLimitController.text) ?? 2,
      status: widget.user.status,
      subLink: widget.user.subLink,
    );

    await widget.onSave(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        blur: 20,
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.neon,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedInboundId,
                  decoration: const InputDecoration(labelText: 'Inbound'),
                  items: _inbounds.map((inbound) {
                    return DropdownMenuItem(
                      value: int.tryParse(inbound.id),
                      child: Text(inbound.remark),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedInboundId = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _trafficLimitController,
                  decoration: const InputDecoration(labelText: 'Traffic Limit (GB)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _daysLimitController,
                  decoration: const InputDecoration(labelText: 'Days Limit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipLimitController,
                  decoration: const InputDecoration(labelText: 'IP Limit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QrDialog extends StatelessWidget {
  final User user;
  const QrDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        blur: 20,
        padding: const EdgeInsets.all(32),
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${user.username}\'s Configuration',
              style: TextStyle(
                color: colors.neon,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImage(
                data: user.subLink,
                version: QrVersions.auto,
                size: 250,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.subLink,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}