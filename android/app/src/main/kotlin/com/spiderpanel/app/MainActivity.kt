package com.spiderpanel.app;

import android.content.Context;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.*;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "spiderpanel/deploy";
    private static final String TAG = "SpiderPanelDeploy";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "deployBackend":
                        deployBackend(call, result);
                        break;
                    case "checkDocker":
                        checkDocker(result);
                        break;
                    case "getDeviceInfo":
                        getDeviceInfo(result);
                        break;
                    case "runCommand":
                        runCommand(call, result);
                        break;
                    case "getPublicIP":
                        getPublicIP(result);
                        break;
                    default:
                        result.notImplemented();
                }
            });
    }

    private void deployBackend(MethodCall call, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                String repoUrl = call.argument("repoUrl") != null ? call.argument("repoUrl") : "https://github.com/amirappleidfd-stack/spider--panel";
                String branch = call.argument("branch") != null ? call.argument("branch") : "main";
                
                // Generate secure tokens
                String backendToken = "spider_backend_" + UUID.randomUUID().toString().replace("-", "");
                String apiKey = UUID.randomUUID().toString().replace("-", "");
                
                // Clone repository
                String tempDir = getCacheDir().getAbsolutePath() + "/spider-panel-deploy";
                executeCommand("rm -rf " + tempDir);
                executeCommand("git clone --depth 1 -b " + branch + " " + repoUrl + " " + tempDir);
                
                // Check for docker-compose or Dockerfile
                String dockerComposePath = tempDir + "/docker-compose.yml";
                String dockerfilePath = tempDir + "/Dockerfile";
                
                // Create .env file
                String envContent = "BACKEND_TOKEN=" + backendToken + "\n" +
                                   "API_KEY=" + apiKey + "\n" +
                                   "ENVIRONMENT=production\n" +
                                   "LOG_LEVEL=info\n" +
                                   "SECRET_KEY=" + UUID.randomUUID().toString().replace("-", "");
                executeCommand("echo '" + envContent + "' > " + tempDir + "/.env");
                
                // Deploy with docker-compose if available, otherwise use docker run
                String deployResult;
                if (new java.io.File(dockerComposePath).exists()) {
                    deployResult = executeCommand("cd " + tempDir + " && docker-compose up -d --build");
                } else if (new java.io.File(dockerfilePath).exists()) {
                    deployResult = executeCommand("cd " + tempDir + " && docker build -t spider-panel . && docker run -d --name spider-panel -p 8080:8080 --env-file .env spider-panel");
                } else {
                    // Fallback to pre-built image
                    deployResult = executeCommand("docker run -d --name spider-panel -p 8080:8080 -e BACKEND_TOKEN=" + backendToken + " -e API_KEY=" + apiKey + " ghcr.io/amirappleidfd-stack/spider-panel:latest");
                }
                
                // Wait for container to be ready
                Thread.sleep(10000);
                
                // Get public IP
                String publicIP = getPublicIPAddress();
                String apiUrl = "http://" + (publicIP != null ? publicIP : "localhost") + ":8080";
                
                // Health check
                String healthCheck = executeCommand("curl -s -o /dev/null -w \"%{http_code}\" " + apiUrl + "/api/setup/status");
                
                Map<String, Object> response = new HashMap<>();
                response.put("success", "200".equals(healthCheck.trim()));
                response.put("api_url", apiUrl);
                response.put("backend_token", backendToken);
                response.put("api_key", apiKey);
                response.put("deployment_id", "deploy_" + System.currentTimeMillis());
                response.put("container_status", "running");
                response.put("logs", deployResult);
                
                result.success(response);
                
            } catch (Exception e) {
                Log.e(TAG, "Deployment failed", e);
                result.error("DEPLOY_ERROR", e.getMessage(), null);
            }
        }).start();
    }

    private void checkDocker(MethodChannel.Result result) {
        new Thread(() -> {
            try {
                String dockerVersion = executeCommand("docker --version");
                String dockerComposeVersion = executeCommand("docker-compose --version");
                String containers = executeCommand("docker ps -a --format \"{{.Names}}\\t{{.Status}}\"");
                
                Map<String, Object> response = new HashMap<>();
                response.put("docker_available", dockerVersion != null && !dockerVersion.isEmpty());
                response.put("docker_version", dockerVersion);
                response.put("docker_compose_version", dockerComposeVersion);
                response.put("containers", containers);
                
                result.success(response);
            } catch (Exception e) {
                result.error("DOCKER_CHECK_ERROR", e.getMessage(), null);
            }
        }).start();
    }

    private void getDeviceInfo(MethodChannel.Result result) {
        Map<String, Object> info = new HashMap<>();
        info.put("model", android.os.Build.MODEL);
        info.put("manufacturer", android.os.Build.MANUFACTURER);
        info.put("android_version", android.os.Build.VERSION.RELEASE);
        info.put("api_level", android.os.Build.VERSION.SDK_INT);
        info.put("architecture", System.getProperty("os.arch"));
        result.success(info);
    }

    private void runCommand(MethodCall call, MethodChannel.Result result) {
        String command = call.argument("command");
        if (command == null) {
            result.error("INVALID_ARGS", "Command is required", null);
            return;
        }
        new Thread(() -> {
            try {
                String output = executeCommand(command);
                result.success(output);
            } catch (Exception e) {
                result.error("COMMAND_ERROR", e.getMessage(), null);
            }
        }).start();
    }

    private void getPublicIP(MethodChannel.Result result) {
        new Thread(() -> {
            try {
                String ip = getPublicIPAddress();
                result.success(ip != null ? ip : "Unknown");
            } catch (Exception e) {
                result.error("IP_ERROR", e.getMessage(), null);
            }
        }).start();
    }

    private String executeCommand(String command) {
        try {
            Process process = Runtime.getRuntime().exec(new String[]{"sh", "-c", command});
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            process.waitFor();
            return output.toString().trim();
        } catch (Exception e) {
            Log.e(TAG, "Command failed: " + command, e);
            return "Error: " + e.getMessage();
        }
    }

    private String getPublicIPAddress() {
        try {
            // Try multiple services for public IP
            String[] services = {
                "https://api.ipify.org",
                "https://ifconfig.me/ip",
                "https://icanhazip.com"
            };
            
            for (String service : services) {
                try {
                    Process process = Runtime.getRuntime().exec(new String[]{"sh", "-c", "curl -s --max-time 5 " + service});
                    BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                    String ip = reader.readLine();
                    process.waitFor();
                    if (ip != null && !ip.isEmpty() && ip.matches("\\d+\\.\\d+\\.\\d+\\.\\d+")) {
                        return ip.trim();
                    }
                } catch (Exception ignored) {}
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to get public IP", e);
        }
        return null;
    }
}