library models;

import 'dart:convert';

enum AppTheme { redNeon, blueNeon, greenNeon }

enum InboundType { mci, mtn, rtl, adsl, custom }

enum UserStatus { active, expired, disabled }

enum ScanStatus { scanning, completed, failed }

class ServerStats {
  final bool status;
  final double cpuUsage;
  final double ramUsage;
  final String network;
  final String xrayStatus;
  final int totalUsers;
  final int activeUsers;
  final int expiredUsers;
  final String totalUsage;
  final String upload;
  final String download;
  final String domain;

  ServerStats({
    required this.status,
    required this.cpuUsage,
    required this.ramUsage,
    required this.network,
    required this.xrayStatus,
    required this.totalUsers,
    required this.activeUsers,
    required this.expiredUsers,
    required this.totalUsage,
    required this.upload,
    required this.download,
    required this.domain,
  });

  factory ServerStats.fromJson(Map<String, dynamic> json) {
    return ServerStats(
      status: json['status'] ?? false,
      cpuUsage: (json['cpu_usage'] ?? 0).toDouble(),
      ramUsage: (json['ram_usage'] ?? 0).toDouble(),
      network: json['network'] ?? 'N/A',
      xrayStatus: json['xray_status'] ?? 'N/A',
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      expiredUsers: json['expired_users'] ?? 0,
      totalUsage: json['total_usage'] ?? '0 GB',
      upload: json['upload'] ?? '0 GB',
      download: json['download'] ?? '0 GB',
      domain: json['domain'] ?? 'N/A',
    );
  }

  static ServerStats mock() {
    return ServerStats(
      status: true,
      cpuUsage: 45.5,
      ramUsage: 62.3,
      network: '10.5 Gbps',
      xrayStatus: 'Running',
      totalUsers: 150,
      activeUsers: 120,
      expiredUsers: 30,
      totalUsage: '2.5 TB',
      upload: '1.2 TB',
      download: '1.3 TB',
      domain: 'panel.example.com',
    );
  }
}

class Inbound {
  final String id;
  final String remark;
  final int port;
  final String ipDomain;
  final String proxyIp;
  final bool enable;
  final String protocol;
  final String security;

  Inbound({
    required this.id,
    required this.remark,
    required this.port,
    required this.ipDomain,
    required this.proxyIp,
    required this.enable,
    required this.protocol,
    required this.security,
  });

  factory Inbound.fromJson(Map<String, dynamic> json) {
    return Inbound(
      id: json['id']?.toString() ?? '',
      remark: json['remark'] ?? '',
      port: json['port'] ?? 443,
      ipDomain: json['ip_domain'] ?? '',
      proxyIp: json['proxy_ip'] ?? '',
      enable: json['enable'] ?? true,
      protocol: json['protocol'] ?? 'vless',
      security: json['security'] ?? 'tls',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remark': remark,
      'port': port,
      'ip_domain': ipDomain,
      'proxy_ip': proxyIp,
      'enable': enable,
      'protocol': protocol,
      'security': security,
    };
  }

  static Inbound mock({required int index}) {
    return Inbound(
      id: 'inbound-$index',
      remark: 'Inbound #$index',
      port: 443 + index,
      ipDomain: 'panel.example.com',
      proxyIp: 'Proxy IP ${index}',
      enable: true,
      protocol: 'vless',
      security: 'tls',
    );
  }
}

class User {
  final String id;
  final String uuid;
  final String username;
  final String email;
  final int inboundId;
  final String inboundRemark;
  final int trafficLimit;
  final int usedTraffic;
  final int daysLimit;
  final DateTime expireDate;
  final int ipLimit;
  final UserStatus status;
  final String subLink;

  User({
    required this.id,
    required this.uuid,
    required this.username,
    required this.email,
    required this.inboundId,
    required this.inboundRemark,
    required this.trafficLimit,
    required this.usedTraffic,
    required this.daysLimit,
    required this.expireDate,
    required this.ipLimit,
    required this.status,
    required this.subLink,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      inboundId: json['inbound_id'] ?? 0,
      inboundRemark: json['inbound_remark'] ?? '',
      trafficLimit: json['traffic_limit'] ?? 0,
      usedTraffic: json['used_traffic'] ?? 0,
      daysLimit: json['days_limit'] ?? 0,
      expireDate: DateTime.tryParse(json['expire_date'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      ipLimit: json['ip_limit'] ?? 0,
      status: _parseStatus(json['status']),
      subLink: json['sub_link'] ?? '',
    );
  }

  static UserStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'expired':
        return UserStatus.expired;
      case 'disabled':
        return UserStatus.disabled;
      default:
        return UserStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'username': username,
      'email': email,
      'inbound_id': inboundId,
      'inbound_remark': inboundRemark,
      'traffic_limit': trafficLimit,
      'used_traffic': usedTraffic,
      'days_limit': daysLimit,
      'expire_date': expireDate.toIso8601String(),
      'ip_limit': ipLimit,
      'status': status.name,
      'sub_link': subLink,
    };
  }

  double get trafficPercent => trafficLimit > 0 ? usedTraffic / trafficLimit : 0.0;

  String get trafficDisplay {
    double usedGb = usedTraffic / (1024 * 1024 * 1024);
    double limitGb = trafficLimit / (1024 * 1024 * 1024);
    return '${usedGb.toStringAsFixed(2)} GB / ${limitGb.toStringAsFixed(2)} GB';
  }

  String get uuidShort => uuid.length > 8 ? '${uuid.substring(0, 8)}...' : uuid;

  static User mock({required int index}) {
    return User(
      id: 'user-$index',
      uuid: 'uuid-${index}-${DateTime.now().millisecondsSinceEpoch}',
      username: 'user$index',
      email: 'user$index@example.com',
      inboundId: 1,
      inboundRemark: 'Inbound #1',
      trafficLimit: 50 * 1024 * 1024 * 1024,
      usedTraffic: (index * 2) * 1024 * 1024 * 1024,
      daysLimit: 30,
      expireDate: DateTime.now().add(const Duration(days: 30)),
      ipLimit: 2,
      status: UserStatus.active,
      subLink: 'https://panel.example.com/sub/uuid-$index',
    );
  }
}

class ScanResult {
  final String ip;
  final int port;
  final int tcpMs;
  final int tlsMs;
  final String status;

  ScanResult({
    required this.ip,
    required this.port,
    required this.tcpMs,
    required this.tlsMs,
    required this.status,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      ip: json['ip'] ?? '',
      port: json['port'] ?? 443,
      tcpMs: json['tcp_ms'] ?? -1,
      tlsMs: json['tls_ms'] ?? -1,
      status: json['status'] ?? 'unknown',
    );
  }

  static ScanResult mock({required int index}) {
    return ScanResult(
      ip: '192.168.1.$index',
      port: 443,
      tcpMs: 45 + index * 2,
      tlsMs: 52 + index * 3,
      status: index % 3 == 0 ? 'Active' : (index % 3 == 1 ? 'Slow' : 'Timeout'),
    );
  }
}

class ScanCategory {
  final String name;
  final String displayName;
  final InboundType type;
  final ScanStatus status;
  final List<ScanResult> results;
  final DateTime? lastScan;
  final String? error;

  ScanCategory({
    required this.name,
    required this.displayName,
    required this.type,
    required this.status,
    required this.results,
    this.lastScan,
    this.error,
  });

  factory ScanCategory.fromJson(Map<String, dynamic> json) {
    return ScanCategory(
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => ScanResult.fromJson(e))
              .toList() ??
          [],
      lastScan: json['last_scan'] != null ? DateTime.tryParse(json['last_scan']) : null,
      error: json['error'],
    );
  }

  static InboundType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mci':
        return InboundType.mci;
      case 'mtn':
        return InboundType.mtn;
      case 'rtl':
        return InboundType.rtl;
      case 'adsl':
        return InboundType.adsl;
      default:
        return InboundType.custom;
    }
  }

  static ScanStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'scanning':
        return ScanStatus.scanning;
      case 'completed':
        return ScanStatus.completed;
      case 'failed':
        return ScanStatus.failed;
      default:
        return ScanStatus.completed;
    }
  }

  static List<ScanCategory> defaults() {
    return [
      ScanCategory(name: 'mci', displayName: 'MCI', type: InboundType.mci, status: ScanStatus.completed, results: []),
      ScanCategory(name: 'mtn', displayName: 'MTN', type: InboundType.mtn, status: ScanStatus.completed, results: []),
      ScanCategory(name: 'rtl', displayName: 'RTL', type: InboundType.rtl, status: ScanStatus.completed, results: []),
      ScanCategory(name: 'adsl', displayName: 'ADSL', type: InboundType.adsl, status: ScanStatus.completed, results: []),
    ];
  }
}

class AppSettings {
  final String panelDomain;
  final String apiKey;
  final String railwayToken;
  final String backendUrl;
  final String edgeTunnelSettings;
  final AppTheme theme;

  AppSettings({
    required this.panelDomain,
    required this.apiKey,
    required this.railwayToken,
    required this.backendUrl,
    required this.edgeTunnelSettings,
    required this.theme,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      panelDomain: json['panel_domain'] ?? '',
      apiKey: json['api_key'] ?? '',
      railwayToken: json['railway_token'] ?? '',
      backendUrl: json['backend_url'] ?? '',
      edgeTunnelSettings: json['edge_tunnel_settings'] ?? '',
      theme: AppSettings._parseThemeFromJson(json['theme']),
    );
  }

  static AppTheme _parseThemeFromJson(dynamic theme) {
    if (theme is String) {
      switch (theme) {
        case 'redNeon':
          return AppTheme.redNeon;
        case 'blueNeon':
          return AppTheme.blueNeon;
        default:
          return AppTheme.greenNeon;
      }
    }
    return AppTheme.greenNeon;
  }

  Map<String, dynamic> toJson() {
    return {
      'panel_domain': panelDomain,
      'api_key': apiKey,
      'railway_token': railwayToken,
      'backend_url': backendUrl,
      'edge_tunnel_settings': edgeTunnelSettings,
      'theme': theme.name,
    };
  }

  static AppSettings defaultSettings() {
    return AppSettings(
      panelDomain: '',
      apiKey: '',
      railwayToken: '',
      backendUrl: 'https://api.example.com',
      edgeTunnelSettings: '',
      theme: AppTheme.greenNeon,
    );
  }

  AppSettings copyWith({
    String? panelDomain,
    String? apiKey,
    String? railwayToken,
    String? backendUrl,
    String? edgeTunnelSettings,
    AppTheme? theme,
  }) {
    return AppSettings(
      panelDomain: panelDomain ?? this.panelDomain,
      apiKey: apiKey ?? this.apiKey,
      railwayToken: railwayToken ?? this.railwayToken,
      backendUrl: backendUrl ?? this.backendUrl,
      edgeTunnelSettings: edgeTunnelSettings ?? this.edgeTunnelSettings,
      theme: theme ?? this.theme,
    );
  }
}

class ProfileInfo {
  final String domain;
  final String apiKey;
  final String railwayToken;
  final String accountStatus;
  final int maxAccounts;

  ProfileInfo({
    required this.domain,
    required this.apiKey,
    required this.railwayToken,
    required this.accountStatus,
    required this.maxAccounts,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      domain: json['domain'] ?? '',
      apiKey: json['api_key'] ?? '',
      railwayToken: json['railway_token'] ?? '',
      accountStatus: json['account_status'] ?? 'Active',
      maxAccounts: json['max_accounts'] ?? 5,
    );
  }

  static ProfileInfo mock() {
    return ProfileInfo(
      domain: 'panel.example.com',
      apiKey: 'sk-xxxxxxxxxxxxxxxxxxxxxxxx',
      railwayToken: 'railway-token-****',
      accountStatus: 'Active',
      maxAccounts: 5,
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  ApiResponse({required this.success, this.message, this.data, this.statusCode});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? parser) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && parser != null ? parser(json['data']) : null,
      statusCode: json['status_code'],
    );
  }
}