import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تثبيت الاتجاه الرأسي وإخفاء أشرطة النظام لتجربة شاشة كاملة حقيقية
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050508),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const YahyaRgbApp());
}

class YahyaRgbApp extends StatelessWidget {
  const YahyaRgbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'يحيى RGB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050508),
      ),
      home: const YahyaHomeScreen(),
    );
  }
}

enum ColorPaletteType { rainbow, cyberpunk, aurora, fire, vaporwave }

class YahyaHomeScreen extends StatefulWidget {
  const YahyaHomeScreen({super.key});

  @override
  State<YahyaHomeScreen> createState() => _YahyaHomeScreenState();
}

class _YahyaHomeScreenState extends State<YahyaHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // إعدادات التحكم الديناميكية
  double _speed = 1.0;
  double _density = 1.0;
  double _glowIntensity = 0.7;
  double _angleDegrees = 90.0;
  ColorPaletteType _currentPalette = ColorPaletteType.rainbow;
  bool _isUIVisible = true;

  @override
  void initState() {
    super.initState();
    // تحكم دوراني مستمر متوافق مع معدل 120Hz
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // توليد قائمة الألوان بناءً على النمط والوقت
  List<Color> _calculateGradientColors(double progress) {
    final double phase = (progress * 360 * _speed) % 360;

    switch (_currentPalette) {
      case ColorPaletteType.rainbow:
        return List.generate(7, (index) {
          final double hue = (phase + (index * 60 * _density)) % 360;
          return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
        });

      case ColorPaletteType.cyberpunk:
        final c1 = HSVColor.fromAHSV(1.0, (180 + math.sin(progress * 6.28) * 20) % 360, 1.0, 1.0).toColor();
        final c2 = HSVColor.fromAHSV(1.0, (320 + math.cos(progress * 6.28) * 30) % 360, 1.0, 1.0).toColor();
        final c3 = HSVColor.fromAHSV(1.0, (55 + math.sin(progress * 9.42) * 15) % 360, 1.0, 1.0).toColor();
        final c4 = HSVColor.fromAHSV(1.0, (280 + math.cos(progress * 6.28) * 20) % 360, 1.0, 1.0).toColor();
        return [c1, c2, c3, c4, c1];

      case ColorPaletteType.aurora:
        final offset = math.sin(progress * 6.28) * 35;
        final c1 = HSVColor.fromAHSV(1.0, (140 + offset) % 360, 1.0, 0.9).toColor();
        final c2 = HSVColor.fromAHSV(1.0, (180 + offset) % 360, 1.0, 1.0).toColor();
        final c3 = HSVColor.fromAHSV(1.0, (270 - offset) % 360, 0.9, 1.0).toColor();
        return [c1, c2, c3, c1];

      case ColorPaletteType.fire:
        final offset = math.sin(progress * 6.28) * 25;
        final c1 = HSVColor.fromAHSV(1.0, (355 + offset) % 360, 1.0, 1.0).toColor();
        final c2 = HSVColor.fromAHSV(1.0, (25 + offset) % 360, 1.0, 1.0).toColor();
        final c3 = HSVColor.fromAHSV(1.0, (48 + offset) % 360, 1.0, 1.0).toColor();
        return [c1, c2, c3, c1];

      case ColorPaletteType.vaporwave:
        final c1 = HSVColor.fromAHSV(1.0, 190, 0.9, 1.0).toColor();
        final c2 = HSVColor.fromAHSV(1.0, (270 + phase * 0.2) % 360, 0.85, 1.0).toColor();
        final c3 = HSVColor.fromAHSV(1.0, (330 + phase * 0.2) % 360, 0.9, 1.0).toColor();
        return [c1, c2, c3, c1];
    }
  }

  // حساب نقاط بداية ونهاية التدرج بناءً على الزاوية
  Alignment _getAlignment(double angle, bool isStart) {
    final rad = angle * math.pi / 180;
    final double x = math.cos(rad);
    final double y = math.sin(rad);
    return isStart ? Alignment(-x, -y) : Alignment(x, y);
  }

  void _triggerHaptic() {
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _isUIVisible = !_isUIVisible;
          });
        },
        child: Stack(
          children: [
            // خلفية الجزيئات الضوئية المتحركة
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final colors = _calculateGradientColors(_animController.value);
                return CustomPaint(
                  size: size,
                  painter: AmbientParticlesPainter(
                    progress: _animController.value,
                    primaryColor: colors.first,
                  ),
                );
              },
            ),

            // اسم "يحيى" المعروض مع التدرج وتأثير النيون
            Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final colors = _calculateGradientColors(_animController.value);
                  final gradient = LinearGradient(
                    begin: _getAlignment(_angleDegrees, true),
                    end: _getAlignment(_angleDegrees, false),
                    colors: colors,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الاسم الأساسي
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // طبقة التوهج النيوني المحيطية (Aura Glow)
                          if (_glowIntensity > 0)
                            Text(
                              'يحيى',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.reemKufi(
                                fontSize: size.width * 0.32,
                                fontWeight: FontWeight.bold,
                                color: colors.first.withOpacity(_glowIntensity * 0.8),
                                shadows: [
                                  Shadow(
                                    color: colors.first.withOpacity(_glowIntensity),
                                    blurRadius: 40 * _glowIntensity,
                                  ),
                                  Shadow(
                                    color: colors[colors.length ~/ 2].withOpacity(_glowIntensity),
                                    blurRadius: 80 * _glowIntensity,
                                  ),
                                ],
                              ),
                            ),

                          // الاسم المتلون بالتدرج اللوني الحقيقي
                          ShaderMask(
                            shaderCallback: (bounds) => gradient.createShader(bounds),
                            child: Text(
                              'يحيى',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.reemKufi(
                                fontSize: size.width * 0.32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // انعكاس زجاجي ناعم أسفل الاسم
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(1.0, -0.28)
                          ..translate(0.0, -10.0),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.transparent,
                            ],
                          ).createShader(bounds),
                          blendMode: BlendMode.dstIn,
                          child: ShaderMask(
                            shaderCallback: (bounds) => gradient.createShader(bounds),
                            child: Text(
                              'يحيى',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.reemKufi(
                                fontSize: size.width * 0.32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // زر إظهار لوحة التحكم عند الإخفاء
            if (!_isUIVisible)
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF161622).withOpacity(0.8),
                  elevation: 6,
                  onPressed: () {
                    _triggerHaptic();
                    setState(() => _isUIVisible = true);
                  },
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
              ),

            // لوحة التحكم الزجاجية الشفافة
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              bottom: _isUIVisible ? 0 : -520,
              left: 0,
              right: 0,
              child: _buildGlassControlPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // بناء لوحة التحكم بجمالية الـ Glassmorphism
  Widget _buildGlassControlPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A).withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مؤشر السحب والإغلاق
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تخصيص تأثيرات الألوان',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => setState(() => _isUIVisible = false),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // اختيار نمط الألوان
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPaletteChip('RGB طيفي', ColorPaletteType.rainbow),
                  _buildPaletteChip('سايبربانك', ColorPaletteType.cyberpunk),
                  _buildPaletteChip('الشفق القطبي', ColorPaletteType.aurora),
                  _buildPaletteChip('نار وذهب', ColorPaletteType.fire),
                  _buildPaletteChip('فابورويف', ColorPaletteType.vaporwave),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // شريط السرعة
            _buildSliderRow(
              title: 'سرعة التدرج',
              valueText: '${_speed.toStringAsFixed(1)}x',
              value: _speed,
              min: 0.1,
              max: 5.0,
              onChanged: (val) {
                _triggerHaptic();
                setState(() => _speed = val);
              },
            ),

            // شريط كثافة الألوان
            _buildSliderRow(
              title: 'كثافة الألوان',
              valueText: '${(_density * 100).toInt()}%',
              value: _density,
              min: 0.3,
              max: 3.0,
              onChanged: (val) {
                _triggerHaptic();
                setState(() => _density = val);
              },
            ),

            // شريط شدة النيون
            _buildSliderRow(
              title: 'شدة توهج النيون',
              valueText: '${(_glowIntensity * 100).toInt()}%',
              value: _glowIntensity,
              min: 0.0,
              max: 1.0,
              onChanged: (val) {
                _triggerHaptic();
                setState(() => _glowIntensity = val);
              },
            ),

            // شريط زاوية الانسياب
            _buildSliderRow(
              title: 'زاوية الانسياب',
              valueText: '${_angleDegrees.toInt()}°',
              value: _angleDegrees,
              min: 0.0,
              max: 360.0,
              onChanged: (val) {
                _triggerHaptic();
                setState(() => _angleDegrees = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteChip(String label, ColorPaletteType type) {
    final bool isSelected = _currentPalette == type;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ChoiceChip(
        label: Text(label),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white,
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF00FFCC),
        backgroundColor: Colors.white.withOpacity(0.08),
        onSelected: (selected) {
          if (selected) {
            _triggerHaptic();
            setState(() => _currentPalette = type);
          }
        },
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: GoogleFonts.tajawal(fontSize: 13, color: Colors.white70),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF00FFCC),
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF00FFCC).withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                trackHeight: 3,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              valueText,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFF00FFCC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسم جزيئات النجوم الحركية في الخلفية
class AmbientParticlesPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  AmbientParticlesPainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 40; i++) {
      final double initialX = random.nextDouble() * size.width;
      final double initialY = random.nextDouble() * size.height;
      final double speed = (random.nextDouble() * 0.4 + 0.1);
      final double currentY = (initialY + (progress * 100 * speed)) % size.height;
      final double radius = random.nextDouble() * 1.8 + 0.6;
      final double alpha = (math.sin(progress * 6.28 + i) * 0.3 + 0.4).clamp(0.1, 0.7);

      paint.color = primaryColor.withOpacity(alpha);
      canvas.drawCircle(Offset(initialX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AmbientParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.primaryColor != primaryColor;
  }
}
