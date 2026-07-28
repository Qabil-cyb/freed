import 'dart:async';
import 'package:flutter/services.dart';

class DeployService {
  static const MethodChannel _channel = MethodChannel('spiderpanel/deploy');
  
  static const String REPO_URL = 'https://github.com/amirappleidfd-stack/spider--panel';

  /// Deploy Spider Panel backend
  static Future<DeployResult> deployBackend({
    String? repoUrl,
    String? branch,
    Function(DeployProgress)? onProgress,
  }) async {
    try {
      onProgress?.call(DeployProgress(step: 'Cloning repository...', percent: 10));
      
      final Map<String, dynamic> result = await _channel.invokeMethod('deployBackend', {
        'repoUrl': repoUrl ?? REPO_URL,
        'branch': branch ?? 'main',
      });
      
      onProgress?.call(DeployProgress(step: 'Deployment complete!', percent: 100));
      
      return DeployResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw DeployException(e.message ?? 'Deployment failed');
    }
  }

  /// Check Docker availability
  static Future<DockerInfo> checkDocker() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('checkDocker');
      return DockerInfo.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw DeployException(e.message ?? 'Docker check failed');
    }
  }

  /// Get device information
  static Future<DeviceInfo> getDeviceInfo() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('getDeviceInfo');
      return DeviceInfo.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw DeployException(e.message ?? 'Device info failed');
    }
  }

  /// Run arbitrary command
  static Future<String> runCommand(String command) async {
    try {
      final String result = await _channel.invokeMethod('runCommand', {'command': command});
      return result;
    } on PlatformException catch (e) {
      throw DeployException(e.message ?? 'Command failed');
    }
  }

  /// Get public IP address
  static Future<String> getPublicIP() async {
    try {
      final String result = await _channel.invokeMethod('getPublicIP');
      return result;
    } on PlatformException catch (e) {
      throw DeployException(e.message ?? 'IP lookup failed');
    }
  }
}

class DeployProgress {
  final String step;
  final int percent;
  
  DeployProgress({required this.step, required this.percent});
}

class DeployResult {
  final bool success;
  final String apiUrl;
  final String backendToken;
  final String apiKey;
  final String deploymentId;
  final String containerStatus;
  final String logs;
  
  DeployResult({
    required this.success,
    required this.apiUrl,
    required this.backendToken,
    required this.apiKey,
    required this.deploymentId,
    required this.containerStatus,
    required this.logs,
  });
  
  factory DeployResult.fromMap(Map<String, dynamic> map) {
    return DeployResult(
      success: map['success'] ?? false,
      apiUrl: map['api_url'] ?? '',
      backendToken: map['backend_token'] ?? '',
      apiKey: map['api_key'] ?? '',
      deploymentId: map['deployment_id'] ?? '',
      containerStatus: map['container_status'] ?? '',
      logs: map['logs'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'success': success,
    'api_url': apiUrl,
    'backend_token': backendToken,
    'api_key': apiKey,
    'deployment_id': deploymentId,
    'container_status': containerStatus,
    'logs': logs,
  };
}

class DockerInfo {
  final bool dockerAvailable;
  final String dockerVersion;
  final String dockerComposeVersion;
  final String containers;
  
  DockerInfo({
    required this.dockerAvailable,
    required this.dockerVersion,
    required this.dockerComposeVersion,
    required this.containers,
  });
  
  factory DockerInfo.fromMap(Map<String, dynamic> map) {
    return DockerInfo(
      dockerAvailable: map['docker_available'] ?? false,
      dockerVersion: map['docker_version'] ?? '',
      dockerComposeVersion: map['docker_compose_version'] ?? '',
      containers: map['containers'] ?? '',
    );
  }
}

class DeviceInfo {
  final String model;
  final String manufacturer;
  final String androidVersion;
  final int apiLevel;
  final String architecture;
  
  DeviceInfo({
    required this.model,
    required this.manufacturer,
    required this.androidVersion,
    required this.apiLevel,
    required this.architecture,
  });
  
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      model: map['model'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      androidVersion: map['android_version'] ?? '',
      apiLevel: map['api_level'] ?? 0,
      architecture: map['architecture'] ?? '',
    );
  }
}

class DeployException implements Exception {
  final String message;
  DeployException(this.message);
  
  @override
  String toString() => 'DeployException: $message';
}