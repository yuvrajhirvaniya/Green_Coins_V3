import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/core/utils/shared_prefs_helper.dart';
import 'package:green_coins_app/features/auth/presentation/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page data
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Green Coins',
      'description': 'Your eco-friendly recycling rewards platform. Join us in making the world greener, one recycling action at a time.',
      'icon': Icons.eco,
      'color': Color(0xFF4CAF50), // Green
      'image': 'assets/images/onboarding_welcome.png',
      'features': [
        'Join a global eco-friendly community',
        'Track your environmental impact',
        'Make a difference with every recycling action',
      ],
    },
    {
      'title': 'Recycle and Earn',
      'description': 'Turn your recyclable waste into virtual coins. The more you recycle, the more coins you earn to spend on eco-friendly products.',
      'icon': Icons.recycling,
      'color': Color(0xFF2196F3), // Blue
      'image': 'assets/images/onboarding_recycle.png',
      'features': [
        'Simple and easy recycling process',
        'Earn virtual coins for each item',
        'Watch your rewards grow over time',
      ],
    },
    {
      'title': 'Shop Eco-Friendly Products',
      'description': 'Redeem your coins for sustainable products in our eco-store. Make a positive impact with every purchase.',
      'icon': Icons.shopping_bag,
      'color': AppTheme.primaryColor,
      'image': 'assets/images/onboarding_shop.png',
      'features': [
        'Browse a wide range of sustainable products',
        'Redeem your earned coins for purchases',
        'Support eco-friendly businesses and initiatives',
      ],
    },
  ];

  // Animation controller for entrance animations
  late AnimationController _entranceAnimationController;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    // Initialize animation controller
    _entranceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Start entrance animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
        _entranceAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    // Mark onboarding as seen
    await SharedPrefsHelper.setOnboardingSeen();

    if (!mounted) return;

    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentPage];
    final currentColor = currentPage['color'] as Color;

    return Scaffold(
      body: Stack(
        children: [
          // Simple, elegant background
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  currentColor.withAlpha(15),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

          // Subtle decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentColor.withAlpha(10),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentColor.withAlpha(8),
              ),
            ),
          ),

          // Main content with entrance animations
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceAnimationController,
              builder: (context, child) {
                return Column(
                  children: [
                // Header with logo and skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _entranceAnimationController.value)),
                    child: Opacity(
                      opacity: _entranceAnimationController.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      // App logo with enhanced design
                      Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              key: ValueKey<int>(_currentPage), // Key to trigger animation when page changes
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    currentColor.withAlpha(40),
                                    currentColor.withAlpha(10),
                                  ],
                                  stops: const [0.4, 1.0],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                currentPage['icon'] as IconData, // Use current page's icon
                                color: currentColor,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Green Coins',
                            style: TextStyle(
                              color: currentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      // Skip button
                      TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: currentColor,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                      ),
                    ),
                  ),
                ),

                // Progress indicator removed
                const SizedBox(height: 16),

                // Page view with enhanced animations
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      // Add animation based on page position relative to current page
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
                          }

                          return Transform.scale(
                            scale: Curves.easeOutQuint.transform(value),
                            child: Transform.translate(
                              offset: Offset(value * 50.0 * (index - (_pageController.hasClients ? _pageController.page ?? index : index)), 0),
                              child: Opacity(
                                opacity: Curves.easeOutQuint.transform(value),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _buildOnboardingPage(
                          title: page['title'] as String,
                          description: page['description'] as String,
                          icon: page['icon'] as IconData,
                          color: page['color'] as Color,
                          image: page['image'] as String?,
                          features: page['features'] as List<String>,
                        ),
                      );
                    },
                  ),
                ),

                // Bottom navigation with animation
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Transform.translate(
                    offset: Offset(0, -30 * (1 - _entranceAnimationController.value)),
                    child: Opacity(
                      opacity: _entranceAnimationController.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      // Page indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                          spacing: 5,
                          activeDotColor: currentColor,
                          dotColor: Colors.grey.shade300,
                        ),
                      ),

                      // Next/Get Started button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                      ),
                    ),
                  ),
                ),
              ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? image,
    required List<String> features, // Keep parameter to avoid changing method signature
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add more extra space at the top
            const SizedBox(height: 60),
            // Image or Icon
            if (image != null)
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: Image.asset(
                  image,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return _buildIconContainer(icon, color);
                  },
                ),
              )
            else
              _buildIconContainer(icon, color),

            // Title
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Description
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Features section removed as requested
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withAlpha(50),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 80,
        color: color,
      ),
    );
  }


}
