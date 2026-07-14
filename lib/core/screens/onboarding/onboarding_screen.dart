import 'package:flutter/material.dart';
import 'package:resturnt_app/core/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome',
      'desc': 'Manage all your restaurant orders in one place.',
    },
    {
      'title': 'Stay Organized',
      'desc': 'Track order status and keep everything organized.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          index == 0
                              ? 'assets/images/photo1.png'
                              : 'assets/images/photo2.png',
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),

                        // نص العنوان
                        Text(
                          _onboardingData[index]['title']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F964A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // نص الوصف
                        Text(
                          _onboardingData[index]['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    // إذا كانت هادي الصفحة الحالية، بنخلي النقطة عريضة (مطوطة)
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xff0F964A)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2️⃣ زر الانتقال (Next) السفلي
              ElevatedButton(
                onPressed: () {
                  // إذا كنا في الصفحة الأولى، ينتقل للصفحة الثانية بحركة ناعمة
                  if (_currentPage < _onboardingData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xff0F964A,
                  ), // أخضر منارة المعتمد
                  minimumSize: const Size(
                    double.infinity,
                    52,
                  ), // عرض كامل وارتفاع مريح
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // حواف ناعمة
                  ),
                ),
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
