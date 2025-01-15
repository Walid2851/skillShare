import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import '../controller/auth_controller.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _circleController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  // Logo animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoOpacityAnimation;

  // Circle animations
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _circleOpacityAnimation;
  late Animation<Color?> _circleColorAnimation;

  // Text animations
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;

  // Final fade transition
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimationControllers();
    _createAnimations();
    _startAnimationSequence();
  }

  void _setupAnimationControllers() {
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _circleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
  }

  void _createAnimations() {
    // Logo animations with bouncy effect
    _logoScaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_logoController);

    _logoRotateAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Circle animations with color transition
    _circleScaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_circleController);

    _circleOpacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _circleColorAnimation = ColorTween(
      begin: Colors.blue.shade400,
      end: Colors.purple.shade300,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));

    // Text slide up and fade in
    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Final fade out
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_fadeController);
  }

  Future<void> _startAnimationSequence() async {
    try {
      // Start logo animation
      await _logoController.forward();

      // Start circle animation
      await _circleController.forward();

      // Start text animation after a short delay
      await Future.delayed(Duration(milliseconds: 300));
      await _textController.forward();

      // Wait for some time before fading out
      await Future.delayed(Duration(milliseconds: 800));
      await _fadeController.forward();

      // Navigate to LoginScreen after fade out
      Get.off(
            () => LoginScreen(),
        transition: Transition.fade,
        duration: Duration(milliseconds: 600),
      );
    } catch (e) {
      // Handle any errors during the animation sequence
      print("Animation sequence error: $e");
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _circleController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _circleController,
          _textController,
          _fadeController,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Animated circles
                Center(
                  child: Opacity(
                    opacity: 1.0 - _circleOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _circleScaleAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _circleColorAnimation.value?.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      Transform.rotate(
                        angle: _logoRotateAnimation.value * 3.14159,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade300,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Animated text
                      Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade300,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your journey continues here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _obscurePassword = true;

  // Add staggered animations for form elements
  late List<AnimationController> _elementAnimationControllers;
  late List<Animation<Offset>> _elementSlideAnimations;

  @override
  void initState() {
    super.initState();

    // Main form animation
    _formAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Initialize staggered animations for form elements
    _elementAnimationControllers = List.generate(
      4,
          (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      ),
    );

    _elementSlideAnimations = _elementAnimationControllers.map((controller) {
      return Tween<Offset>(
        begin: Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    // Start animations in sequence
    _formAnimationController.forward().then((_) {
      for (var i = 0; i < _elementAnimationControllers.length; i++) {
        Future.delayed(
          Duration(milliseconds: i * 100),
              () => _elementAnimationControllers[i].forward(),
        );
      }
    });
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    for (var controller in _elementAnimationControllers) {
      controller.dispose();
    }
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _formFadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildAlternativeLogin(),
                      const SizedBox(height: 24),
                      _buildSignUpLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _elementSlideAnimations[0],
      child: FadeTransition(
        opacity: _elementAnimationControllers[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ).createShader(bounds),
              child: Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue your journey',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildAnimatedTextField(
          controller: emailController,
          hint: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          slideAnimation: _elementSlideAnimations[1],
          fadeAnimation: _elementAnimationControllers[1],
        ),
        _buildAnimatedTextField(
          controller: passwordController,
          hint: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          slideAnimation: _elementSlideAnimations[2],
          fadeAnimation: _elementAnimationControllers[2],
        ),
        _buildForgotPassword(),
        const SizedBox(height: 16),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    required Animation<Offset> slideAnimation,
    required Animation<double> fadeAnimation,
  }) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.black38),
              prefixIcon: Icon(icon, color: Colors.blue, size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.blue,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '$hint is required';
              }
              if (hint == 'Email' && !GetUtils.isEmail(value!)) {
                return 'Invalid email format';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SlideTransition(
      position: _elementSlideAnimations[3],
      child: FadeTransition(
        opacity: _elementAnimationControllers[3],
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                authController.signIn(
                  emailController.text,
                  passwordController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue.shade700,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
        Text(
          'Or continue with',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoginOption(
          icon: Icons.facebook,
          color: Color(0xFF1877F2),
          onTap: () {},
        ),
        SizedBox(width: 20),
        _buildLoginOption(
          icon: Icons.g_mobiledata,
          color: Color(0xFFDB4437),
          onTap: () {},
        ),
        SizedBox(width: 20),
        _buildLoginOption(
          icon: Icons.apple,
          color: Colors.black,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLoginOption({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 32,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: () => Get.to(() => SignupScreen()),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            children: [
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: "Sign up",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}