import 'package:flutter/material.dart';
import 'login_screen.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: 'Welcome to Bill Splitter',
      description: 'Split bills easily with friends, family, and colleagues. No more awkward math or forgotten payments!',
      icon: Icons.receipt_long,
      color: Colors.blue,
      illustration: 'assets/tutorial_1.png',
    ),
    TutorialPage(
      title: 'Create or Join Groups',
      description: 'Start by creating a new group or join an existing one with a group code. Add members easily!',
      icon: Icons.group_add,
      color: Colors.green,
      illustration: 'assets/tutorial_2.png',
    ),
    TutorialPage(
      title: 'Choose Your Bill Type',
      description: 'Whether it\'s a trip, lodging, or dining - we have specialized forms for every occasion.',
      icon: Icons.category,
      color: Colors.orange,
      illustration: 'assets/tutorial_3.png',
    ),
    TutorialPage(
      title: 'Smart Bill Splitting',
      description: 'Our app calculates fair splits automatically. For dining, split by individual items!',
      icon: Icons.calculate,
      color: Colors.purple,
      illustration: 'assets/tutorial_4.png',
    ),
    TutorialPage(
      title: 'Track Payments',
      description: 'Monitor who\'s paid and send friendly reminders. Share bills via QR codes instantly!',
      icon: Icons.payment,
      color: Colors.teal,
      illustration: 'assets/tutorial_5.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[_currentPage].color.withOpacity(0.1),
              _pages[_currentPage].color.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill Splitter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _pages[_currentPage].color,
                      ),
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page indicator
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].color
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildTutorialPage(_pages[index]),
                    );
                  },
                ),
              ),

              // Bottom Navigation
              Container(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    _currentPage > 0
                        ? TextButton.icon(
                            onPressed: _previousPage,
                            icon: Icon(Icons.arrow_back_ios, size: 16),
                            label: Text('Previous'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                            ),
                          )
                        : SizedBox(width: 100),

                    // Next/Get Started button
                    ElevatedButton(
                      onPressed: _currentPage < _pages.length - 1
                          ? _nextPage
                          : _goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage < _pages.length - 1
                                ? 'Next'
                                : 'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            _currentPage < _pages.length - 1
                                ? Icons.arrow_forward_ios
                                : Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
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

  Widget _buildTutorialPage(TutorialPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration (replace with actual images if available)
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: page.color.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  page.icon,
                  size: 80,
                  color: page.color,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: page.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Feature ${_pages.indexOf(page) + 1}',
                    style: TextStyle(
                      color: page.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24),

          // Description
          Container(
            constraints: BoxConstraints(maxWidth: 320),
            child: Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String illustration;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.illustration,
  });
}
