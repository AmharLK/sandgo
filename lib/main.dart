import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

void main() {
  runApp(const SandGoApp());
}

class SandGoApp extends StatelessWidget {
  const SandGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SandGo - Premium Ride Service',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFB800),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Controllers for smooth animations
  late AnimationController fadeAnimation;
  late AnimationController slideAnimation;
  late AnimationController pulseAnimation;
  late AnimationController particleAnimation;
  
  // User selections
  String currentCity = "Riyadh";
  String currentVehicle = "Economy";
  
  // Available options
  final cities = ["Riyadh", "Jeddah", "Dammam", "Makkah", "Medina"];
  final vehicleTypes = ["Economy", "Comfort", "Premium", "SUV"];

  @override
  void initState() {
    super.initState();
    
    // Initialize fade in animation
    fadeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Initialize slide animation
    slideAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Initialize pulse animation for glowing effects
    pulseAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Initialize particle animation for floating elements
    particleAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Start animations
    fadeAnimation.forward();
    slideAnimation.forward();
  }

  @override
  void dispose() {
    fadeAnimation.dispose();
    slideAnimation.dispose();
    pulseAnimation.dispose();
    particleAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 1024;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background with animated particles
          _buildAnimatedBackground(),
          
          // Main scrollable content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildTopBar(isWideScreen),
                SliverToBoxAdapter(
                  child: isWideScreen 
                      ? _buildWideScreenLayout(screenSize)
                      : _buildNarrowScreenLayout(screenSize),
                ),
              ],
            ),
          ),
          
          // Floating action buttons
          _buildFloatingActions(),
        ],
      ),
    );
  }

  // Background with image and animated particles
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1694018359679-49465b4c0d61?fm=jpg&q=60&w=3000',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF0F3460),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Dark gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.95),
                ],
              ),
            ),
          ),
        ),
        
        // Animated floating particles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  animationValue: particleAnimation.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Top navigation bar
  Widget _buildTopBar(bool isWideScreen) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      snap: true,
      expandedHeight: 80,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: EdgeInsets.only(
            left: isWideScreen ? 80 : 20,
            bottom: 20,
          ),
          title: Row(
            children: [
              // Logo with glow effect
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(
                            0.3 + (pulseAnimation.value * 0.3)
                          ),
                          blurRadius: 15 + (pulseAnimation.value * 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi,
                      color: Colors.black,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'SandGo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB800),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isWideScreen) ...[
          _buildNavButton('Services'),
          _buildNavButton('About'),
          _buildNavButton('Contact'),
          const SizedBox(width: 20),
          _buildSignInButton(),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFFFB800)),
            onPressed: () => _showMenu(),
          ),
        ],
        const SizedBox(width: 20),
      ],
    );
  }

  // Desktop/Wide screen layout
  Widget _buildWideScreenLayout(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Hero content
          Expanded(
            flex: 5,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.3, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: slideAnimation,
                  curve: Curves.easeOut,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    _buildHeroContent(),
                    const SizedBox(height: 60),
                    _buildFeatures(),
                    const SizedBox(height: 60),
                    _buildStats(),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 60),
          
          // Right side - Booking form
          Expanded(
            flex: 3,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: slideAnimation,
                  curve: Curves.easeOut,
                )),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    _buildBookingForm(),
                    const SizedBox(height: 30),
                    _buildPromotion(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile/Narrow screen layout
  Widget _buildNarrowScreenLayout(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeroContent(),
          const SizedBox(height: 40),
          _buildBookingForm(),
          const SizedBox(height: 40),
          _buildFeatures(),
          const SizedBox(height: 40),
          _buildStats(),
          const SizedBox(height: 40),
          _buildPromotion(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Hero section with main heading
  Widget _buildHeroContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 500;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB800).withOpacity(0.2),
                    const Color(0xFFFF8C00).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFB800).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            const Color(0xFFFFB800),
                            const Color(0xFFFF8C00),
                            pulseAnimation.value,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB800).withOpacity(
                                0.5 + (pulseAnimation.value * 0.5)
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Available 24/7',
                    style: TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Main heading
            Text(
              'Your Journey,',
              style: TextStyle(
                fontSize: isSmallScreen ? 36 : 56,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFFFFB800),
                    Color(0xFFFF8C00),
                    Color(0xFFFFD700),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'Our Priority',
                style: TextStyle(
                  fontSize: isSmallScreen ? 36 : 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description with Arabic
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFB800).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Experience premium ride services across Saudi Arabia',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 18,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'خدمة نقل فاخرة عبر المملكة العربية السعودية',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 18,
                      color: const Color(0xFFFFB800),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Call to action buttons
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withOpacity(
                              0.4 + (pulseAnimation.value * 0.3)
                            ),
                            blurRadius: 20 + (pulseAnimation.value * 10),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Scroll or navigate to booking
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB800),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24 : 32,
                            vertical: isSmallScreen ? 16 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                OutlinedButton.icon(
                  onPressed: () {
                    // Show info or video
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24 : 32,
                      vertical: isSmallScreen ? 16 : 20,
                    ),
                    side: const BorderSide(color: Colors.white38, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  label: Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Booking form card
  Widget _buildBookingForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_location_alt,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Book Your Ride',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Pickup location input
              _buildInputField(
                label: 'Pickup Location',
                hint: 'Enter your location',
                icon: Icons.my_location,
              ),
              
              const SizedBox(height: 20),
              
              // Destination input
              _buildInputField(
                label: 'Destination',
                hint: 'Where to?',
                icon: Icons.location_on,
              ),
              
              const SizedBox(height: 20),
              
              // City selector
              _buildCityPicker(),
              
              const SizedBox(height: 20),
              
              // Vehicle type selector
              _buildVehiclePicker(),
              
              const SizedBox(height: 30),
              
              // Confirm booking button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showConfirmation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB800),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 12),
                      Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Fare estimate
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB800).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Fare',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'SAR 45 - 60',
                      style: TextStyle(
                        color: Color(0xFFFFB800),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input field widget
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFFB800), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // City picker dropdown
  Widget _buildCityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select City',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentCity,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A2E),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFFFB800),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        color: Color(0xFFFFB800),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(city),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  currentCity = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // Vehicle type picker
  Widget _buildVehiclePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Type',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: vehicleTypes.map((vehicle) {
            final isSelected = vehicle == currentVehicle;
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentVehicle = vehicle;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  vehicle,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Features grid
  Widget _buildFeatures() {
    final featuresList = [
      {
        'icon': Icons.verified_user,
        'title': 'Safe & Secure',
        'desc': 'Verified drivers',
      },
      {
        'icon': Icons.schedule,
        'title': 'Quick Pickup',
        'desc': 'Average 5 min',
      },
      {
        'icon': Icons.payment,
        'title': 'Easy Payment',
        'desc': 'Multiple options',
      },
      {
        'icon': Icons.support_agent,
        'title': '24/7 Support',
        'desc': 'Always available',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 4 : 2;
        final isSmallScreen = constraints.maxWidth <= 600;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: isSmallScreen ? 12 : 20,
            mainAxisSpacing: isSmallScreen ? 12 : 20,
            childAspectRatio: isSmallScreen ? 1.1 : 1.2,
          ),
          itemCount: featuresList.length,
          itemBuilder: (context, index) {
            final feature = featuresList[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: Colors.black,
                          size: isSmallScreen ? 22 : 28,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 12),
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 13 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        feature['desc'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Statistics section
  Widget _buildStats() {
    final statsList = [
      {'value': '1M+', 'label': 'Happy Riders'},
      {'value': '50K+', 'label': 'Professional Drivers'},
      {'value': '25+', 'label': 'Cities Covered'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFB800).withOpacity(0.15),
                    const Color(0xFFFF8C00).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFB800).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: statsList.map((stat) {
                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [Color(0xFFFFB800), Color(0xFFFFD700)],
                            ).createShader(bounds);
                          },
                          child: Text(
                            stat['value'] as String,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          stat['label'] as String,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 10 : 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Promotional offer card
  Widget _buildPromotion() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFB800).withOpacity(0.2),
                const Color(0xFFFF8C00).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFB800).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.local_offer,
                color: Color(0xFFFFB800),
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                'Special Offer!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get 20% off on your first ride',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FIRST20',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation button for desktop
  Widget _buildNavButton(String text) {
    return TextButton(
      onPressed: () {
        // Navigate to section
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Sign in button
  Widget _buildSignInButton() {
    return OutlinedButton(
      onPressed: () {
        // Show sign in
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFFB800),
        side: const BorderSide(color: Color(0xFFFFB800), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Floating action buttons
  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 30,
      right: 30,
      child: Column(
        children: [
          _buildActionButton(Icons.phone, 'Call'),
          const SizedBox(height: 12),
          _buildActionButton(Icons.chat, 'Chat'),
        ],
      ),
    );
  }

  // Individual action button
  Widget _buildActionButton(IconData icon, String tooltip) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withOpacity(
                  0.4 * pulseAnimation.value
                ),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: tooltip,
            onPressed: () {
              // Handle action
            },
            backgroundColor: const Color(0xFFFFB800),
            child: Icon(icon, color: Colors.black),
          ),
        );
      },
    );
  }

  // Show mobile menu
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
                border: const Border(
                  top: BorderSide(color: Color(0xFFFFB800), width: 2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...[
                    {'icon': Icons.miscellaneous_services, 'title': 'Services'},
                    {'icon': Icons.info_outline, 'title': 'About'},
                    {'icon': Icons.contact_mail, 'title': 'Contact'},
                    {'icon': Icons.login, 'title': 'Sign In'},
                  ].map((item) {
                    return ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFFFFB800),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => Navigator.pop(context),
                    );
                  }).toList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show booking confirmation
  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      const Color(0xFF1A1A2E).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFB800).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.black,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your ride to $currentCity is confirmed.\nDriver will arrive in 5 minutes.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Close'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB800),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Track Ride'),
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
      },
    );
  }
}

// Custom painter for animated particles
class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Generate particles
    for (int i = 0; i < 50; i++) {
      final x = (i * 47.0 + animationValue * 200) % size.width;
      final y = (i * 73.0 + animationValue * 100) % size.height;
      final radius = 1.0 + (i % 3);
      final opacity = 0.1 + ((i % 5) * 0.05);
      
      paint.color = const Color(0xFFFFB800).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}