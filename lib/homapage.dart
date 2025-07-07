import 'package:fingerprint/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation for the fingerprint icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for button press
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1A1A2E),
      body: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color(0xFF1A1A2E),
          //     Color(0xFF16213E),
          //     Color(0xFF0F3460),
          //   ],
          // ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildMainContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          _buildAuthenticationIcon(),
          const SizedBox(height: 40),
          _buildStatusText(),
          const SizedBox(height: 60),
          _buildAuthButton(),
          const SizedBox(height: 40),
          _buildFooterText(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Secure Access',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Authenticate to continue',
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticationIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAuthenticated ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isAuthenticated
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.deepPurple, Colors.deepPurple],
              ),
            ),
            child: Icon(
              _isAuthenticated ? Icons.check : Icons.fingerprint,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(_isAuthenticated),
        children: [
          Text(
            _isAuthenticated
                ? 'Authentication Successful!'
                : 'Ready to Authenticate',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _isAuthenticated ? Colors.green.shade400 : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAuthButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: _isAuthenticated
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.deepPurple, Colors.deepPurple],
              ),

            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _isLoading ? null : _authenticate,
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) => _scaleController.reverse(),
                onTapCancel: () => _scaleController.reverse(),
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            // valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isAuthenticated ? Icons.refresh : Icons.fingerprint,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isAuthenticated ? 'Authenticate Again' : 'Authenticate',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterText() {
    return Text(
      'Your biometric data is stored securely on your device',
      style: TextStyle(
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _authenticate() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bool canAuthenticate = await _auth.canCheckBiometrics || 
          await _auth.isDeviceSupported();
      
      if (canAuthenticate) {
        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Please authenticate to proceed',
          options: const AuthenticationOptions(biometricOnly: false),
        );

        setState(() {
          _isAuthenticated = didAuthenticate;
          _isLoading = false;
        });

        if (didAuthenticate) {
          // Stop the pulse animation when authenticated
          _pulseController.stop();
          
          // Add a small delay before navigation for better UX
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, homeTabsScreenRoute);
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          _showSnackBar('Biometric authentication not available on this device.');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showSnackBar('Authentication failed: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}