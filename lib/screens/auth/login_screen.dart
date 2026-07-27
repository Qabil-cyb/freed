import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/auth_provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _panelUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;
  
  bool _isLogin = true;
  bool _showApiFields = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    
    _logoRotation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    
    _formSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );
    
    _formController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    _panelUrlController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GalaxyBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedBuilder(
                animation: _formController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _formSlide.value),
                    child: Opacity(
                      opacity: _formFade.value,
                      child: _buildContent(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with spider animation
        AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoScale.value,
              child: Transform.rotate(
                angle: _logoRotation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonBlue.withOpacity(0.3),
                        AppColors.neonPurple.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(80, 80),
                      painter: SpiderLogoPainter(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Made by Amir text
        Text(
          'Made by Amir',
          style: TextStyle(
            color: AppColors.neonBlue.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Glass Card with Form
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _isLogin 
                    ? 'Sign in to manage your Spider VPN Panel'
                    : 'Set up your admin account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.danger, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Register fields
                if (!_isLogin) ...[
                  GlassInputField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _fullNameController,
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  GlassInputField(
                    label: 'Username',
                    hint: 'Choose a username',
                    controller: _usernameController,
                    icon: Icons.alternate_email,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Email
                GlassInputField(
                  label: 'Email',
                  hint: 'admin@spiderpanel.com',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password
                GlassInputField(
                  label: 'Password',
                  hint: _isLogin ? 'Enter password' : 'Min 6 characters',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!_isLogin && v.length < 6) return 'Min 6 chars';
                    return null;
                  },
                ),
                
                // API Key & Panel URL fields
                if (_showApiFields) ...[
                  const SizedBox(height: 16),
                  GlassInputField(
                    label: 'Panel URL',
                    hint: 'http://your-server:54321',
                    controller: _panelUrlController,
                    icon: Icons.link,
                    keyboardType: TextInputType.url,
                    validator: _showApiFields 
                      ? (v) => v == null || v.isEmpty ? 'Required' : null
                      : null,
                  ),
                  const SizedBox(height: 16),
                  GlassInputField(
                    label: 'API Key',
                    hint: 'Enter your XUI panel API key',
                    controller: _apiKeyController,
                    icon: Icons.vpn_key,
                    obscureText: true,
                    validator: _showApiFields 
                      ? (v) => v == null || v.isEmpty ? 'Required' : null
                      : null,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Submit button
                GlassButton(
                  label: _isLogin ? 'Sign In' : 'Create Account',
                  icon: _isLogin ? Icons.login : Icons.person_add,
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
                
                const SizedBox(height: 16),
                
                // Toggle API fields
                TextButton.icon(
                  icon: Icon(
                    _showApiFields ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.neonBlue,
                  ),
                  label: Text(
                    _showApiFields ? 'Hide Panel Settings' : 'Add Panel (API Key & URL)',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () => setState(() => _showApiFields = !_showApiFields),
                ),
                
                const SizedBox(height: 16),
                
                // Switch mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleMode,
                      child: Text(
                        _isLogin ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          color: AppColors.neonBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Version info
        Text(
          'Spider VPN Panel v1.0.0',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
      _formController.reset();
      _formController.forward();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authProvider = context.read<AuthProvider>();
      bool success;
      
      if (_isLogin) {
        success = await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          apiKey: _showApiFields && _apiKeyController.text.isNotEmpty 
            ? _apiKeyController.text.trim() 
            : null,
          panelUrl: _showApiFields && _panelUrlController.text.isNotEmpty
            ? _panelUrlController.text.trim()
            : null,
        );
      } else {
        success = await authProvider.register(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim().isNotEmpty 
            ? _fullNameController.text.trim() 
            : null,
          apiKey: _showApiFields && _apiKeyController.text.isNotEmpty 
            ? _apiKeyController.text.trim() 
            : null,
          panelUrl: _showApiFields && _panelUrlController.text.isNotEmpty
            ? _panelUrlController.text.trim()
            : null,
        );
      }
      
      if (!success && mounted) {
        setState(() {
          _error = authProvider.error ?? 'Authentication failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}

class SpiderLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 800;

    // Right legs (blue neon)
    final rightLegPaint = Paint()
      ..color = AppColors.neonBlue
      ..strokeWidth = 3 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Left legs (blue neon)
    final leftLegPaint = Paint()
      ..color = AppColors.neonBlue
      ..strokeWidth = 3 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body (purple neon)
    final bodyPaint = Paint()
      ..color = AppColors.neonPurple
      ..strokeWidth = 4 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Joints (glowing dots)
    final jointPaint = Paint()
      ..color = AppColors.neonBlue
      ..style = PaintingStyle.fill;

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw right legs
    _drawRightLegs(canvas, center, rightLegPaint, jointPaint, scale);
    // Draw left legs
    _drawLeftLegs(canvas, center, leftLegPaint, jointPaint, scale);
    // Draw body
    _drawBody(canvas, center, bodyPaint, scale);
    // Draw eyes
    _drawEyes(canvas, center, eyePaint, scale);
  }

  void _drawRightLegs(Canvas canvas, Offset center, Paint legPaint, Paint jointPaint, double scale) {
    // Right legs paths
    final paths = [
      [Offset(215 * scale, -20 * scale), Offset(275 * scale, -100 * scale), Offset(375 * scale, -140 * scale), Offset(445 * scale, -70 * scale), Offset(475 * scale, 50 * scale)],
      [Offset(230 * scale, 10 * scale), Offset(315 * scale, -50 * scale), Offset(435 * scale, -40 * scale), Offset(515 * scale, 60 * scale), Offset(535 * scale, 160 * scale)],
      [Offset(230 * scale, 40 * scale), Offset(305 * scale, 70 * scale), Offset(415 * scale, 140 * scale), Offset(475 * scale, 250 * scale), Offset(455 * scale, 370 * scale)],
      [Offset(215 * scale, 80 * scale), Offset(275 * scale, 170 * scale), Offset(345 * scale, 280 * scale), Offset(365 * scale, 400 * scale), Offset(305 * scale, 450 * scale)],
    ];

    for (final points in paths) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, legPaint);
      
      // Draw joints
      for (final point in points) {
        canvas.drawCircle(point, 2 * scale, jointPaint);
      }
    }
  }

  void _drawLeftLegs(Canvas canvas, Offset center, Paint legPaint, Paint jointPaint, double scale) {
    final paths = [
      [Offset(-215 * scale, -20 * scale), Offset(-275 * scale, -100 * scale), Offset(-375 * scale, -140 * scale), Offset(-445 * scale, -70 * scale), Offset(-475 * scale, 50 * scale)],
      [Offset(-230 * scale, 10 * scale), Offset(-315 * scale, -50 * scale), Offset(-435 * scale, -40 * scale), Offset(-515 * scale, 60 * scale), Offset(-535 * scale, 160 * scale)],
      [Offset(-230 * scale, 40 * scale), Offset(-305 * scale, 70 * scale), Offset(-415 * scale, 140 * scale), Offset(-475 * scale, 250 * scale), Offset(-455 * scale, 370 * scale)],
      [Offset(-215 * scale, 80 * scale), Offset(-275 * scale, 170 * scale), Offset(-345 * scale, 280 * scale), Offset(-365 * scale, 400 * scale), Offset(-305 * scale, 450 * scale)],
    ];

    for (final points in paths) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, legPaint);
      
      for (final point in points) {
        canvas.drawCircle(point, 2 * scale, jointPaint);
      }
    }
  }

  void _drawBody(Canvas canvas, Offset center, Paint bodyPaint, double scale) {
    // Cephalothorax
    final cephalothorax = Path();
    cephalothorax.moveTo(-40 * scale, 50 * scale);
    cephalothorax.cubicTo(
      -40 * scale, -20 * scale,
      40 * scale, -20 * scale,
      40 * scale, 50 * scale,
    );
    cephalothorax.cubicTo(
      50 * scale, 90 * scale,
      20 * scale, 110 * scale,
      0, 110 * scale,
    );
    cephalothorax.cubicTo(
      -20 * scale, 110 * scale,
      -50 * scale, 90 * scale,
      -40 * scale, 50 * scale,
    );
    canvas.drawPath(cephalothorax, bodyPaint);

    // Abdomen
    final abdomen = Path();
    abdomen.moveTo(0, 110 * scale);
    abdomen.cubicTo(
      70 * scale, 110 * scale,
      100 * scale, 220 * scale,
      80 * scale, 300 * scale,
    );
    abdomen.cubicTo(
      50 * scale, 400 * scale,
      -50 * scale, 400 * scale,
      -80 * scale, 300 * scale,
    );
    abdomen.cubicTo(
      -100 * scale, 220 * scale,
      -70 * scale, 110 * scale,
      0, 110 * scale,
    );
    canvas.drawPath(abdomen, bodyPaint);

    // Abdomen patterns
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2 * scale
      ..style = PaintingStyle.stroke;
    
    // Pattern 1
    final pattern1 = Path();
    pattern1.moveTo(0, 150 * scale);
    pattern1.lineTo(25 * scale, 210 * scale);
    pattern1.lineTo(0, 260 * scale);
    pattern1.lineTo(-25 * scale, 210 * scale);
    pattern1.close();
    canvas.drawPath(pattern1, patternPaint);
    
    // Pattern 2
    final pattern2 = Path();
    pattern2.moveTo(0, 280 * scale);
    pattern2.lineTo(12 * scale, 310 * scale);
    pattern2.lineTo(0, 340 * scale);
    pattern2.lineTo(-12 * scale, 310 * scale);
    pattern2.close();
    canvas.drawPath(pattern2, patternPaint);
  }

  void _drawEyes(Canvas canvas, Offset center, Paint eyePaint, double scale) {
    // Main eyes
    canvas.drawCircle(Offset(-15 * scale, -55 * scale), 3.5 * scale, eyePaint);
    canvas.drawCircle(Offset(15 * scale, -55 * scale), 3.5 * scale, eyePaint);
    
    // Reflections
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-22 * scale, -45 * scale), 2 * scale, reflectionPaint);
    canvas.drawCircle(Offset(22 * scale, -45 * scale), 2 * scale, reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}