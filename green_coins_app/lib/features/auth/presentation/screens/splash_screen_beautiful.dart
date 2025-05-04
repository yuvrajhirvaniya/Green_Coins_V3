import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/core/utils/shared_prefs_helper.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/auth/presentation/screens/login_screen.dart';
import 'package:green_coins_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:green_coins_app/features/home/presentation/screens/main_screen.dart';
import 'dart:developer' as developer;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math' as math;

// Leaf particle class for animated leaves
class LeafParticle {
  double x; // x position (0-1)
  double y; // y position (0-1)
  double size; // size of the leaf
  double rotation; // rotation angle
  double speed; // falling speed
  double rotationSpeed; // rotation speed
  int leafType; // type of leaf (different shapes)
  double delay; // animation delay

  LeafParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.rotationSpeed,
    required this.leafType,
    required this.delay,
  });
}

// Wave painter for the animated wave effect
class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;

    // Start path at bottom left
    path.moveTo(0, height);

    // Create wave pattern
    for (double i = 0; i < width; i++) {
      final x = i;
      final y = height - 20 * math.sin((x / width * 2 * math.pi) + animation.value * 2 * math.pi) - 10;
      path.lineTo(x, y);
    }

    // Complete the path
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Main animations
  late AnimationController _mainAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // Background animations
  late AnimationController _backgroundAnimationController;

  // Leaf animations
  late AnimationController _leafAnimationController;

  // Shimmer effect
  late AnimationController _shimmerController;

  // Wave animation
  late AnimationController _waveController;

  // State variables
  bool _showContent = false;
  final List<LeafParticle> _leaves = [];

  @override
  void initState() {
    super.initState();

    // Generate random leaves
    _generateLeaves();

    // Initialize main animations
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Curves.easeInOutBack,
      ),
    );

    // Initialize background animations
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // Initialize leaf animations
    _leafAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // Initialize shimmer effect
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Initialize wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Start animations
    _backgroundAnimationController.repeat();
    _leafAnimationController.repeat();
    _shimmerController.repeat(reverse: true);
    _waveController.repeat(reverse: true);

    _mainAnimationController.forward().then((_) {
      setState(() {
        _showContent = true;
      });

      // Delay before checking auth status
      Future.delayed(const Duration(milliseconds: 3000), () {
        _checkAuthStatus();
      });
    });
  }

  void _generateLeaves() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _leaves.add(
        LeafParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 20 + 10,
          rotation: random.nextDouble() * 2 * math.pi,
          speed: random.nextDouble() * 0.2 + 0.1,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.1,
          leafType: random.nextInt(3),
          delay: random.nextDouble() * 10,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _leafAnimationController.dispose();
    _shimmerController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user has seen onboarding
    final hasSeenOnboarding = await SharedPrefsHelper.hasSeenOnboarding();
    developer.log('Has seen onboarding: $hasSeenOnboarding', name: 'SplashScreen');

    if (!mounted) return;

    // Check authentication status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // Navigate based on auth status and onboarding status
    if (!hasSeenOnboarding) {
      // First-time user, show onboarding
      developer.log('First-time user, showing onboarding screen', name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (authProvider.status == AuthStatus.authenticated) {
      // Returning authenticated user, go to main screen
      developer.log('Returning authenticated user, navigating to MainScreen', name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Returning unauthenticated user, go to login
      developer.log('Returning unauthenticated user, navigating to LoginScreen', name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final random = math.Random();

    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 0, 150, 136), // Teal
                      Color.fromARGB(255, 46, 125, 50), // Dark Green
                      Color.fromARGB(255, 56, 142, 60), // Green
                      Color.fromARGB(255, 76, 175, 80), // Light Green
                    ],
                    stops: [
                      0.0 + _backgroundAnimationController.value * 0.1,
                      0.3 + _backgroundAnimationController.value * 0.1,
                      0.6 + _backgroundAnimationController.value * 0.1,
                      0.9 + _backgroundAnimationController.value * 0.1,
                    ],
                  ),
                ),
              );
            },
          ),

          // Animated particles (circles)
          ...List.generate(30, (index) {
            final size = random.nextInt(15) + 5.0;
            final x = random.nextDouble() * screenSize.width;
            final y = random.nextDouble() * screenSize.height;
            final opacity = random.nextDouble() * 0.5 + 0.1;
            final delay = random.nextInt(3000);
            final duration = 3000 + random.nextInt(7000);

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((opacity * 255).toInt()),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha((opacity * 100).toInt()),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .fadeIn(duration: 1000.ms, delay: delay.ms)
              .then()
              .move(
                duration: duration.ms,
                delay: delay.ms,
                curve: Curves.easeInOut,
                begin: Offset(0, 0),
                end: Offset(
                  random.nextDouble() * 150 - 75,
                  random.nextDouble() * 150 - 75,
                ),
              )
              .then()
              .fadeOut(duration: 1000.ms)
              .then()
              .fadeIn(duration: 1000.ms),
            );
          }),

          // Animated leaves
          ...List.generate(_leaves.length, (index) {
            final leaf = _leaves[index];
            return AnimatedBuilder(
              animation: _leafAnimationController,
              builder: (context, child) {
                // Calculate current position based on animation
                final time = (_leafAnimationController.value + leaf.delay) % 1.0;
                final x = leaf.x * screenSize.width + math.sin(time * 10) * 50;
                final y = ((leaf.y + time * leaf.speed) % 1.0) * screenSize.height;
                final rotation = leaf.rotation + time * leaf.rotationSpeed * 10;

                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity: 0.7,
                      child: Icon(
                        leaf.leafType == 0
                            ? Icons.eco
                            : leaf.leafType == 1
                                ? Icons.spa
                                : Icons.local_florist,
                        color: Colors.white.withAlpha(150),
                        size: leaf.size,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Bottom wave
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animation: _waveController,
                    color: Colors.white.withAlpha(40),
                  ),
                  size: Size(screenSize.width, 100),
                );
              },
            ),
          ),

          // Second wave (offset)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animation: ReverseAnimation(_waveController),
                    color: Colors.white.withAlpha(25),
                  ),
                  size: Size(screenSize.width, 80),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or app icon with animations
                AnimatedBuilder(
                  animation: _mainAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Shimmer effect
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  return Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withAlpha(100),
                                          Colors.transparent,
                                        ],
                                        stops: [
                                          0.0,
                                          _shimmerController.value,
                                          1.0,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Icon
                              Icon(
                                Icons.recycling,
                                size: 100,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width < 300 ? 20 : 50
                ),

                // App name with animation
                if (_showContent)
                  _buildAppName(),

                SizedBox(
                  height: MediaQuery.of(context).size.width < 300 ? 10 : 20
                ),

                // Tagline with animation
                if (_showContent)
                  _buildTagline(),

                SizedBox(
                  height: MediaQuery.of(context).size.width < 300 ? 30 : 60
                ),

                // Loading indicator with animation
                if (_showContent)
                  _buildLoadingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the app name widget with animations
  Widget _buildAppName() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isExtremelySmallScreen = screenWidth < 300; // For very narrow devices like v2027
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isExtremelySmallScreen ? 10 : isSmallScreen ? 20 : 40
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isExtremelySmallScreen ? 10 : isSmallScreen ? 16 : 24, 
        vertical: isExtremelySmallScreen ? 6 : isSmallScreen ? 8 : 12
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(40),
            Colors.white.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(
          isExtremelySmallScreen ? 15 : isSmallScreen ? 20 : 30
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: isExtremelySmallScreen ? 10 : 15,
            spreadRadius: isExtremelySmallScreen ? 1 : 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(50),
          width: isExtremelySmallScreen ? 1.0 : 1.5,
        ),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFE0F7FA), // Light cyan
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: isExtremelySmallScreen ? 28 : isSmallScreen ? 36 : 44,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: isExtremelySmallScreen ? 1.0 : isSmallScreen ? 1.5 : 2.0,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: isExtremelySmallScreen ? 8 : 10,
                  offset: isExtremelySmallScreen ? const Offset(1, 1) : const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true, period: 3000.ms),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: 800.ms,
      curve: Curves.easeOutQuad,
    ).then().shimmer(
      duration: 3000.ms,
      delay: 800.ms,
      color: Colors.white.withAlpha(100),
    );
  }
  
  // Build the tagline widget with animations
  Widget _buildTagline() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    final isExtremelySmallScreen = screenWidth < 300; // For very narrow devices like v2027
    
    // For v2027 and similar extremely small devices, use an ultra-minimal layout
    if (isExtremelySmallScreen) {
      // Use a simple row with "Save Earth" text
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, color: Colors.green.shade300, size: 16),
          const SizedBox(width: 4),
          const Text(
            'Save Earth',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ).animate().fadeIn(
        delay: 300.ms,
        duration: 800.ms,
      );
    }
    
    // For other screen sizes, use a more decorative container
    Widget taglineWidget = Container(
      margin: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 15 : isSmallScreen ? 20 : 40),
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 10 : isSmallScreen ? 12 : 20,
        vertical: isVerySmallScreen ? 5 : isSmallScreen ? 8 : 10
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withAlpha(80),
            Colors.teal.withAlpha(40),
          ],
        ),
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 20 : isSmallScreen ? 30 : 50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, color: Colors.green.shade300, size: isVerySmallScreen ? 16 : 20),
          SizedBox(width: isVerySmallScreen ? 4 : 8),
          Text(
            'Save Earth',
            style: TextStyle(
              color: Colors.white,
              fontSize: isVerySmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              letterSpacing: isVerySmallScreen ? 0.5 : 1.0,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    return taglineWidget.animate().fadeIn(
      delay: 300.ms,
      duration: 800.ms,
    ).slideY(
      begin: 0.3,
      end: 0,
      delay: 300.ms,
      duration: 800.ms,
      curve: Curves.easeOutQuad,
    ).then().blurXY(
      begin: 5,
      end: 0,
      duration: 500.ms,
      delay: 300.ms,
    );
  }
  
  // Build the loading indicator with animations
  Widget _buildLoadingIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtremelySmallScreen = screenWidth < 300; // For very narrow devices like v2027
    
    final padding = isExtremelySmallScreen ? 10.0 : 16.0;
    final ringSize = isExtremelySmallScreen ? 40.0 : 60.0;
    final pulseSize = isExtremelySmallScreen ? 25.0 : 40.0;
    final dotSize = isExtremelySmallScreen ? 6.0 : 10.0;
    final lineWidth = isExtremelySmallScreen ? 2.0 : 3.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.white.withAlpha(50),
            Colors.white.withAlpha(10),
          ],
          radius: 1.0,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: isExtremelySmallScreen ? 5 : 10,
            spreadRadius: isExtremelySmallScreen ? 0.5 : 1,
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(30),
          width: isExtremelySmallScreen ? 0.5 : 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer spinning circle
          SpinKitRing(
            color: Colors.white.withAlpha(150),
            size: ringSize,
            lineWidth: lineWidth,
          ),

          // Inner pulsing circle
          SpinKitPulse(
            color: Colors.white,
            size: pulseSize,
          ),

          // Center dot
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(150),
                  blurRadius: isExtremelySmallScreen ? 5 : 10,
                  spreadRadius: isExtremelySmallScreen ? 0.5 : 1,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: 600.ms,
      duration: 800.ms,
    ).then().scaleXY(
      begin: 0.9,
      end: 1.0,
      duration: 1500.ms,
    ).then().custom(
      duration: 2000.ms,
      builder: (context, value, child) => Transform.rotate(
        angle: math.sin(value * math.pi * 2) * 0.05,
        child: child,
      ),
    );
  }
}
