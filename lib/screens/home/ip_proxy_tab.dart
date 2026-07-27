import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:spider_vpn/services/api_service.dart';

class IPProxyTab extends StatefulWidget {
  const IPProxyTab({super.key});

  @override
  State<IPProxyTab> createState() => _IPProxyTabState();
}

class _IPProxyTabState extends State<IPProxyTab> {
  List<dynamic> _proxies = [];
  List<dynamic> _inbounds = [];
  bool _isLoading = true;
  bool _isBulkImporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService.instance;
      final proxies = await api.getIpProxies();
      final inbounds = await api.getInbounds();
      if (mounted) {
        setState(() {
          _proxies = proxies;
          _inbounds = inbounds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddProxyDialog() {
    final ipCtrl = TextEditingController();
    final portCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedProtocol = 'socks5';
    String selectedCountry = 'US';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.bgDarkCard.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorder.withOpacity(0.3), width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add IP Proxy',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      GlassInputField(
                        controller: ipCtrl,
                        hintText: 'IP Address',
                        prefixIcon: Icons.language_rounded,
                      ),
                      const SizedBox(height: 14),
                      GlassInputField(
                        controller: portCtrl,
                        hintText: 'Port',
                        prefixIcon: Icons.router_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      GlassInputField(
                        controller: usernameCtrl,
                        hintText: 'Username (optional)',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      GlassInputField(
                        controller: passwordCtrl,
                        hintText: 'Password (optional)',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                      const SizedBox(height: 14),
                      // Protocol selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                          color: AppColors.glassLight.withOpacity(0.08),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedProtocol,
                            dropdownColor: AppColors.bgDarkCard,
                            icon: Icon(Icons.expand_more_rounded, color: AppColors.neonBlue),
                            items: ['socks5', 'http', 'https', 'socks4']
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.toUpperCase(),
                                          style: const TextStyle(color: Colors.white)),
                                    ))
                                .toList(),
                            onChanged: (v) => setModalState(() => selectedProtocol = v ?? 'socks5'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Country selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                          color: AppColors.glassLight.withOpacity(0.08),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedCountry,
                            dropdownColor: AppColors.bgDarkCard,
                            icon: Icon(Icons.expand_more_rounded, color: AppColors.neonBlue),
                            items: [
                              'US', 'GB', 'DE', 'FR', 'NL', 'CA', 'AU', 'JP', 'SG', 'KR',
                              'RU', 'BR', 'IN', 'IR', 'AE', 'TR', 'IT', 'ES', 'SE', 'NO', 'FI', 'DK',
                            ].map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  '$c  ${_getCountryName(c)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setModalState(() => selectedCountry = v ?? 'US'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassButton(
                  label: 'Add Proxy',
                  icon: Icons.add_rounded,
                  width: double.infinity,
                  onPressed: () async {
                    if (ipCtrl.text.isEmpty || portCtrl.text.isEmpty) return;
                    Navigator.pop(context);
                    try {
                      await ApiService.instance.addIpProxy({
                        'ip': ipCtrl.text,
                        'port': int.tryParse(portCtrl.text) ?? 0,
                        'protocol': selectedProtocol,
                        'country': selectedCountry,
                        if (usernameCtrl.text.isNotEmpty) 'username': usernameCtrl.text,
                        if (passwordCtrl.text.isNotEmpty) 'password': passwordCtrl.text,
                      });
                      _loadData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkImportDialog() {
    final bulkCtrl = TextEditingController();
    final countryCtrl = TextEditingController();
    final protocolCtrl = TextEditingController(text: 'socks5');
    String? selectedInbound;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.bgDarkCard.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorder.withOpacity(0.3), width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bulk Import Proxies',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload ip.txt file or paste proxy list',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      // File upload button
                      GlassButton(
                        label: 'Upload ip.txt',
                        icon: Icons.upload_file_rounded,
                        onPressed: () async {
                          try {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['txt'],
                            );
                            if (result != null) {
                              final bytes = result.files.single.bytes;
                              if (bytes != null) {
                                final content = utf8.decode(bytes);
                                bulkCtrl.text = content;
                                setModalState(() {});
                              }
                            }
                          } catch (e) {
                            // File picker may not work on all platforms
                          }
                        },
                        width: double.infinity,
                      ),
                      const SizedBox(height: 14),
                      GlassInputField(
                        controller: bulkCtrl,
                        hintText: 'ip:port:username:password per line',
                        maxLines: 8,
                      ),
                      const SizedBox(height: 14),
                      // Country selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                          color: AppColors.glassLight.withOpacity(0.08),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedInbound,
                            dropdownColor: AppColors.bgDarkCard,
                            icon: Icon(Icons.expand_more_rounded, color: AppColors.neonBlue),
                            hint: Text('Apply to inbound (optional)',
                                style: TextStyle(color: AppColors.textSecondary)),
                            items: _inbounds.map<DropdownMenuItem<String>>((inb) {
                              return DropdownMenuItem(
                                value: inb['id']?.toString(),
                                child: Text(
                                  inb['remark']?.toString() ?? 'Inbound ${inb['id']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setModalState(() => selectedInbound = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassButton(
                  label: 'Import Proxies',
                  icon: Icons.cloud_download_rounded,
                  width: double.infinity,
                  isLoading: _isBulkImporting,
                  onPressed: () async {
                    if (bulkCtrl.text.trim().isEmpty) return;
                    setState(() => _isBulkImporting = true);
                    Navigator.pop(context);
                    try {
                      final lines = bulkCtrl.text
                          .trim()
                          .split('\n')
                          .where((l) => l.trim().isNotEmpty)
                          .toList();
                      final proxies = lines.map((line) {
                        final parts = line.trim().split(':');
                        return {
                          'ip': parts.isNotEmpty ? parts[0] : '',
                          'port': parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
                          'username': parts.length > 2 ? parts[2] : '',
                          'password': parts.length > 3 ? parts[3] : '',
                          'protocol': protocolCtrl.text,
                          'country': countryCtrl.text.isNotEmpty ? countryCtrl.text : 'US',
                        };
                      }).toList();

                      await ApiService.instance.bulkImportIpProxies(proxies);
                      _loadData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    } finally {
                      setState(() => _isBulkImporting = false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplyToInboundDialog(Map<String, dynamic> proxy) {
    String? selectedInboundId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: AppColors.bgDarkCard.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.glassBorder.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apply Proxy to Inbound',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                    color: AppColors.glassLight.withOpacity(0.08),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedInboundId,
                      dropdownColor: AppColors.bgDarkCard,
                      icon: Icon(Icons.expand_more_rounded, color: AppColors.neonBlue),
                      hint: Text('Select Inbound', style: TextStyle(color: AppColors.textSecondary)),
                      items: _inbounds.map<DropdownMenuItem<String>>((inb) {
                        return DropdownMenuItem(
                          value: inb['id']?.toString(),
                          child: Text(
                            inb['remark']?.toString() ?? 'Inbound ${inb['id']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedInboundId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  label: 'Apply',
                  icon: Icons.check_rounded,
                  width: double.infinity,
                  onPressed: () async {
                    if (selectedInboundId == null) return;
                    Navigator.pop(ctx);
                    try {
                      await ApiService.instance.applyIpProxy(
                        proxy['id']?.toString() ?? '',
                        selectedInboundId!,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Proxy applied to inbound'),
                            backgroundColor: AppColors.neonGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(Icons.cloud_rounded, color: AppColors.neonBlue, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'IP Proxy Manager',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              GlassContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: 10,
                onTap: _showBulkImportDialog,
                child: Icon(Icons.upload_file_rounded, color: AppColors.neonOrange, size: 22),
              ),
              const SizedBox(width: 8),
              GlassContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: 10,
                onTap: _showAddProxyDialog,
                child: Icon(Icons.add_rounded, color: AppColors.neonGreen, size: 22),
              ),
            ],
          ),
        ),

        // Proxy list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
              : _proxies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_outlined, color: AppColors.textSecondary.withOpacity(0.4), size: 64),
                          const SizedBox(height: 16),
                          Text('No proxies configured',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Tap + to add a proxy',
                              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.neonBlue,
                      backgroundColor: AppColors.bgDarkCard,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _proxies.length,
                        itemBuilder: (context, index) => _buildProxyCard(_proxies[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildProxyCard(Map<String, dynamic> proxy) {
    final ip = proxy['ip']?.toString() ?? 'Unknown';
    final port = proxy['port']?.toString() ?? '0';
    final country = proxy['country']?.toString() ?? 'US';
    final protocol = proxy['protocol']?.toString() ?? 'socks5';
    final isOnline = proxy['is_online'] ?? proxy['online'] ?? true;
    final ping = proxy['ping'] as int?;
    final inboundName = proxy['inbound_name']?.toString();

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        children: [
          // Country flag indicator
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  isOnline == true
                      ? AppColors.neonGreen.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  isOnline == true
                      ? AppColors.neonBlue.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: isOnline == true
                    ? AppColors.neonGreen.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                _getFlagEmoji(country),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$ip:$port',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOnline == true
                            ? AppColors.neonGreen.withOpacity(0.15)
                            : AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOnline == true ? 'ONLINE' : 'OFF',
                        style: TextStyle(
                          color: isOnline == true ? AppColors.neonGreen : AppColors.danger,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$country  ${_getCountryName(country)}',
                      style: TextStyle(color: AppColors.neonBlue, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      protocol.toUpperCase(),
                      style: TextStyle(color: AppColors.neonPurple, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    if (ping != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${ping}ms',
                        style: TextStyle(color: AppColors.neonGreen, fontSize: 11),
                      ),
                    ],
                  ],
                ),
                if (inboundName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '→ $inboundName',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          // Apply button
          if (inboundName == null)
            GestureDetector(
              onTap: () => _showApplyToInboundDialog(proxy),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.neonBlue.withOpacity(0.15),
                  border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.router_rounded, color: AppColors.neonBlue, size: 14),
                    const SizedBox(width: 4),
                    Text('Apply', style: TextStyle(color: AppColors.neonBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFlagEmoji(String countryCode) {
    final code = countryCode.toUpperCase();
    final flag = String.fromCharCodes(
      code.runes.map((r) => 0x1F1E6 - 0x41 + r),
    );
    return flag;
  }

  String _getCountryName(String code) {
    const names = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'DE': 'Germany',
      'FR': 'France',
      'NL': 'Netherlands',
      'CA': 'Canada',
      'AU': 'Australia',
      'JP': 'Japan',
      'SG': 'Singapore',
      'KR': 'South Korea',
      'RU': 'Russia',
      'BR': 'Brazil',
      'IN': 'India',
      'IR': 'Iran',
      'AE': 'UAE',
      'TR': 'Turkey',
      'IT': 'Italy',
      'ES': 'Spain',
      'SE': 'Sweden',
      'NO': 'Norway',
      'FI': 'Finland',
      'DK': 'Denmark',
    };
    return names[code] ?? code;
  }
}
