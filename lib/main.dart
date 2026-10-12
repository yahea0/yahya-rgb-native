import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050508),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const YahyaRgbUltimateApp());
}

class YahyaRgbUltimateApp extends StatelessWidget {
  const YahyaRgbUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'يحيى RGB 3D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050508),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF00FFCC),
          inactiveTrackColor: Colors.white12,
          thumbColor: Colors.white,
          overlayColor: const Color(0xFF00FFCC).withOpacity(0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          trackHeight: 3,
        ),
      ),
      home: const Main3DExperienceScreen(),
    );
  }
}

// أنماط التدرج
enum GradientMode { linear, radial, sweep, wave }

// أنماط الألوان
enum PaletteMode { preset, custom }

// أنماط أنيميشن تجميع الاسم
enum AssemblyStyle { vortex, gravityDrop, supernova, cyberScan, hologram }

class Main3DExperienceScreen extends StatefulWidget {
  const Main3DExperienceScreen({super.key});

  @override
  State<Main3DExperienceScreen> createState() => _Main3DExperienceScreenState();
}

class _Main3DExperienceScreenState extends State<Main3DExperienceScreen>
    with TickerProviderStateMixin {
  // محركات الحركة
  late AnimationController _colorCycleController;
  late AnimationController _assemblyController;
  late Animation<double> _assemblyAnimation;

  // المتغيرات النصية
  String _displayName = 'يحيى';
  final TextEditingController _textInputController = TextEditingController(text: 'يحيى');

  // زوايا وتحكم الـ 3D
  double _rotX = 0.0;
  double _rotY = 0.0;
  double _rotZ = 0.0;
  double _zoom = 1.0;
  bool _autoRotate3D = false;
  double _depthSlices = 7.0; // سماكة الاسم بالـ 3D

  // إعدادات التدرج والألوان
  double _speed = 1.0;
  double _density = 1.0;
  double _glowIntensity = 0.7;
  double _angleDegrees = 90.0;
  GradientMode _gradientMode = GradientMode.linear;
  PaletteMode _paletteMode = PaletteMode.preset;
  String _presetName = 'rainbow';

  // الألوان المخصصة يدوياً
  List<Color> _customColors = [
    const Color(0xFF00FFCC), // نيون تركواز
    const Color(0xFFFF007F), // فوشيا كهربائي
    const Color(0xFF7928CA), // بنفسجي نيون
  ];

  // أنماط التجميع
  AssemblyStyle _currentAssemblyStyle = AssemblyStyle.vortex;

  // واجهة التحكم
  bool _isPanelVisible = true;
  int _currentTab = 0; // 0: النص والـ 3D | 1: الألوان والتدرج | 2: الإضاءة والحركة

  @override
  void initState() {
    super.initState();

    // دورة الألوان المستمرة
    _colorCycleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // دورة أنيميشن التجميع
    _assemblyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _assemblyAnimation = CurvedAnimation(
      parent: _assemblyController,
      curve: Curves.easeOutBack,
    );

    // تشغيل أنيميشن التجميع لأول مرة عند فتح التطبيق
    _assemblyController.forward();
  }

  @override
  void dispose() {
    _colorCycleController.dispose();
    _assemblyController.dispose();
    _textInputController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.selectionClick();
  }

  void _replayAssembly() {
    _triggerHaptic();
    _assemblyController.reset();
    _assemblyController.forward();
  }

  void _reset3DAngles() {
    _triggerHaptic();
    setState(() {
      _rotX = 0.0;
      _rotY = 0.0;
      _rotZ = 0.0;
      _zoom = 1.0;
    });
  }

  // حساب الألوان الآنية
  List<Color> _getCurrentColors(double t) {
    if (_paletteMode == PaletteMode.custom) {
      final double shift = (t * 360 * _speed) % 360;
      return _customColors.map((color) {
        final hsv = HSVColor.fromColor(color);
        return HSVColor.fromAHSV(
          1.0,
          (hsv.hue + shift) % 360,
          hsv.saturation,
          hsv.value,
        ).toColor();
      }).toList();
    }

    final double phase = (t * 360 * _speed) % 360;
    switch (_presetName) {
      case 'rainbow':
        return List.generate(7, (i) {
          final double h = (phase + (i * 60 * _density)) % 360;
          return HSVColor.fromAHSV(1.0, h, 1.0, 1.0).toColor();
        });
      case 'cyberpunk':
        final c1 = HSVColor.fromAHSV(1.0, (180 + math.sin(t * 6.28) * 20) % 360, 1.0, 1.0).toColor();
        final c2 = HSVColor.fromAHSV(1.0, (320 + math.cos(t * 6.28) * 30) % 360, 1.0, 1.0).toColor();
        final c3 = HSVColor.fromAHSV(1.0, (55 + math.sin(t * 9.42) * 15) % 360, 1.0, 1.0).toColor();
        return [c1, c2, c3, c1];
      case 'aurora':
        final off = math.sin(t * 6.28) * 35;
        final c1 = HSVColor.fromAHSV(1.0, (140 + off) % 360, 1.0, 0.95).toColor();
        final c2 = HSVColor.fromAHSV(1.0, (180 + off) % 360, 1.0, 1.0).toColor();
        final c3 = HSVColor.fromAHSV(1.0, (270 - off) % 360, 0.9, 1.0).toColor();
        return [c1, c2, c3, c1];
      case 'fire':
        final off = math.sin(t * 6.28) * 25;
        return [
          HSVColor.fromAHSV(1.0, (355 + off) % 360, 1.0, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, (25 + off) % 360, 1.0, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, (48 + off) % 360, 1.0, 1.0).toColor(),
        ];
      case 'vaporwave':
      default:
        return [
          HSVColor.fromAHSV(1.0, 190, 0.9, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, (275 + phase * 0.2) % 360, 0.85, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, (330 + phase * 0.2) % 360, 0.95, 1.0).toColor(),
        ];
    }
  }

  // بناء التدرج وفقاً للنمط المختار
  Shader _buildGradientShader(Rect bounds, List<Color> colors, double animProgress) {
    switch (_gradientMode) {
      case GradientMode.linear:
        final rad = _angleDegrees * math.pi / 180;
        final alignStart = Alignment(-math.cos(rad), -math.sin(rad));
        final alignEnd = Alignment(math.cos(rad), math.sin(rad));
        return LinearGradient(
          begin: alignStart,
          end: alignEnd,
          colors: colors,
        ).createShader(bounds);

      case GradientMode.radial:
        return RadialGradient(
          center: Alignment.center,
          radius: 0.85 * _density,
          colors: colors,
        ).createShader(bounds);

      case GradientMode.sweep:
        return SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: math.pi * 2,
          colors: colors,
          transform: GradientRotation(animProgress * math.pi * 2 * _speed),
        ).createShader(bounds);

      case GradientMode.wave:
        final waveOffset = math.sin(animProgress * math.pi * 2 * _speed);
        return LinearGradient(
          begin: Alignment(-1.0 + waveOffset * 0.3, -1.0),
          end: Alignment(1.0 + waveOffset * 0.3, 1.0),
          colors: colors,
        ).createShader(bounds);
    }
  }

  // حساب الحجم التلقائي للخط بناءً على طول الاسم
  double _getDynamicFontSize(double screenWidth) {
    final len = _displayName.trim().isEmpty ? 1 : _displayName.trim().length;
    if (len <= 4) return screenWidth * 0.30;
    if (len <= 7) return screenWidth * (1.1 / len);
    return screenWidth * 0.14;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = _getDynamicFontSize(size.width);

    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _reset3DAngles,
        onScaleStart: (_) {},
        onScaleUpdate: (details) {
          setState(() {
            if (details.pointerCount == 1) {
              // دوران ثلاثي الأبعاد باللمس
              _rotY += details.focalPointDelta.dx * 0.008;
              _rotX -= details.focalPointDelta.dy * 0.008;
            } else if (details.pointerCount >= 2) {
              // تكبير وتصغير بإصبعين
              _zoom = (_zoom * details.scale).clamp(0.5, 2.5);
            }
          });
        },
        child: Stack(
          children: [
            // خلفية النجوم والنيون الحركية
            AnimatedBuilder(
              animation: _colorCycleController,
              builder: (context, _) {
                final colors = _getCurrentColors(_colorCycleController.value);
                return CustomPaint(
                  size: size,
                  painter: ParticlesPainter(
                    progress: _colorCycleController.value,
                    color: colors.first,
                  ),
                );
              },
            ),

            // العرض ثلاثي الأبعاد المركزي للاسم
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_colorCycleController, _assemblyController]),
                builder: (context, _) {
                  final t = _colorCycleController.value;
                  final p = _assemblyAnimation.value;
                  final colors = _getCurrentColors(t);

                  // حساب دوران الـ 3D التلقائي إن كان مفعلاً
                  final currentRotY = _autoRotate3D ? _rotY + (t * math.pi * 2) : _rotY;

                  // حساب تأثير أنيميشن التجميع
                  double animScale = 1.0;
                  double animOpacity = 1.0;
                  double animZOffset = 0.0;
                  double animExtraRotZ = 0.0;
                  double animGlitchX = 0.0;

                  switch (_currentAssemblyStyle) {
                    case AssemblyStyle.vortex:
                      animScale = p.clamp(0.01, 1.0);
                      animOpacity = p.clamp(0.0, 1.0);
                      animZOffset = (1.0 - p) * -500;
                      animExtraRotZ = (1.0 - p) * math.pi * 3;
                      break;
                    case AssemblyStyle.gravityDrop:
                      animScale = p;
                      animOpacity = p.clamp(0.0, 1.0);
                      animZOffset = (1.0 - p) * 350;
                      break;
                    case AssemblyStyle.supernova:
                      animScale = (p < 0.6) ? (p * 2.2) : (1.0 + (1.0 - p) * 0.5);
                      animOpacity = p.clamp(0.0, 1.0);
                      break;
                    case AssemblyStyle.cyberScan:
                      animOpacity = p;
                      animGlitchX = (1.0 - p) * math.sin(t * 30) * 15;
                      break;
                    case AssemblyStyle.hologram:
                      animOpacity = (math.sin(p * math.pi * 6) * 0.3 + 0.7) * p;
                      animGlitchX = (1.0 - p) * (math.Random().nextDouble() - 0.5) * 20;
                      break;
                  }

                  // مصفوفة التحويل ثلاثي الأبعاد (True 3D Projection Matrix)
                  final Matrix4 transformMatrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.0015) // منظور العمق البصري Perspective
                    ..scale(_zoom * animScale, _zoom * animScale, _zoom * animScale)
                    ..rotateX(_rotX)
                    ..rotateY(currentRotY)
                    ..rotateZ(_rotZ + animExtraRotZ)
                    ..translate(animGlitchX, 0.0, animZOffset);

                  return Opacity(
                    opacity: animOpacity.clamp(0.0, 1.0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: transformMatrix,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // توليد طبقات السماكة ثلاثية الأبعاد (3D Depth Extrusion Layers)
                          if (_depthSlices > 1)
                            for (int i = _depthSlices.toInt(); i >= 1; i--)
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..translate(0.0, 0.0, -i * 2.4),
                                child: Text(
                                  _displayName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w900,
                                    color: colors.last.withOpacity((0.15 + (1 - i / _depthSlices) * 0.25).clamp(0.0, 1.0)),
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        blurRadius: 4,
                                        offset: const Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                          // توهج النيون الخارجي (Neon Bloom Glow)
                          if (_glowIntensity > 0)
                            Text(
                              _displayName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.reemKufi(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w900,
                                color: colors.first.withOpacity((_glowIntensity * 0.7).clamp(0.0, 1.0)),
                                shadows: [
                                  Shadow(
                                    color: colors.first.withOpacity(_glowIntensity),
                                    blurRadius: 45 * _glowIntensity,
                                  ),
                                  Shadow(
                                    color: colors[colors.length ~/ 2].withOpacity(_glowIntensity),
                                    blurRadius: 90 * _glowIntensity,
                                  ),
                                ],
                              ),
                            ),

                          // الواجهة الأمامية المتلونة بالتدرج الحقيقي
                          ShaderMask(
                            shaderCallback: (bounds) => _buildGradientShader(bounds, colors, t),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              _displayName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.reemKufi(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // زر إظهار لوحة التحكم عند الإخفاء
            if (!_isPanelVisible)
              Positioned(
                bottom: 28,
                right: 28,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF161624).withOpacity(0.85),
                  elevation: 8,
                  onPressed: () {
                    _triggerHaptic();
                    setState(() => _isPanelVisible = true);
                  },
                  child: const Icon(Icons.tune, color: Color(0xFF00FFCC)),
                ),
              ),

            // لوحة التحكم الزجاجية الشاملة
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              bottom: _isPanelVisible ? 0 : -620,
              left: 0,
              right: 0,
              child: _buildUltimateControlPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // بناء لوحة التحكم المتقدمة والمقسمة إلى تبويبات
  Widget _buildUltimateControlPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101018).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 35,
            spreadRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مؤشر السحب وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 28),
                  onPressed: () {
                    _triggerHaptic();
                    setState(() => _isPanelVisible = false);
                  },
                ),
              ],
            ),

            // شريط التبويبات الثلاثة
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTabButton('الاسم والـ 3D', 0, Icons.view_in_ar),
                  _buildTabButton('الألوان والتدرج', 1, Icons.palette),
                  _buildTabButton('الحركة والنيون', 2, Icons.auto_awesome),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // محتوى التبويب المختار
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildActiveTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _triggerHaptic();
          setState(() => _currentTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00FFCC).withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: const Color(0xFF00FFCC).withOpacity(0.4)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? const Color(0xFF00FFCC) : Colors.white60),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildTextAnd3DTab();
      case 1:
        return _buildColorAndGradientTab();
      case 2:
      default:
        return _buildMotionAndGlowTab();
    }
  }

  // التبويب 1: الاسم والتحكم بالـ 3D
  Widget _buildTextAnd3DTab() {
    return Column(
      key: const ValueKey(0),
      children: [
        // حقل كتابة أي اسم
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _textInputController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.reemKufi(fontSize: 18, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'اكتب أي اسم هنا...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _displayName = val.isEmpty ? 'يحيى' : val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFCC),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                _replayAssembly();
              },
              child: const Text('تأكيد وتجميع', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // أزرار التحكم بالـ 3D والأنيميشن
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton('إعادة الزوايا 3D', Icons.refresh, _reset3DAngles),
            _buildActionButton(
              _autoRotate3D ? 'إيقاف الدوران' : 'دوران 3D تلقائي',
              _autoRotate3D ? Icons.pause_circle : Icons.play_circle,
              () {
                _triggerHaptic();
                setState(() => _autoRotate3D = !_autoRotate3D);
              },
            ),
            _buildActionButton('إعادة التجميع', Icons.auto_awesome, _replayAssembly),
          ],
        ),
        const SizedBox(height: 12),

        // اختيار نمط أنيميشن التجميع
        Align(
          alignment: Alignment.centerRight,
          child: Text('نمط أنيميشن التجميع:', style: GoogleFonts.tajawal(fontSize: 13, color: Colors.white70)),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAssemblyChip('الدوامة الكونية', AssemblyStyle.vortex),
              _buildAssemblyChip('السقوط الجاذبي', AssemblyStyle.gravityDrop),
              _buildAssemblyChip('الانفجار النجمي', AssemblyStyle.supernova),
              _buildAssemblyChip('المسح الليزري', AssemblyStyle.cyberScan),
              _buildAssemblyChip('الهولوغرام', AssemblyStyle.hologram),
            ],
          ),
        ),
      ],
    );
  }

  // التبويب 2: الألوان والتدرجات
  Widget _buildColorAndGradientTab() {
    return Column(
      key: const ValueKey(1),
      children: [
        // نوع التدرج (خطي، دائري، حلزوني، موجي)
        Align(
          alignment: Alignment.centerRight,
          child: Text('كيفية انسياب التدرج:', style: GoogleFonts.tajawal(fontSize: 13, color: Colors.white70)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildGradientChip('خطي', GradientMode.linear),
            _buildGradientChip('إشعاعي', GradientMode.radial),
            _buildGradientChip('حلزوني', GradientMode.sweep),
            _buildGradientChip('موجي', GradientMode.wave),
          ],
        ),
        const SizedBox(height: 12),

        // وضع الألوان (جاهز أم مخصص)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('نظام الألوان:', style: GoogleFonts.tajawal(fontSize: 13, color: Colors.white70)),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('قوالب جاهزة'),
                  selected: _paletteMode == PaletteMode.preset,
                  selectedColor: const Color(0xFF00FFCC),
                  onSelected: (_) {
                    _triggerHaptic();
                    setState(() => _paletteMode = PaletteMode.preset);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('ألوان يدوية مخصصة'),
                  selected: _paletteMode == PaletteMode.custom,
                  selectedColor: const Color(0xFF00FFCC),
                  onSelected: (_) {
                    _triggerHaptic();
                    setState(() => _paletteMode = PaletteMode.custom);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // إما عرض القوالب أو منتقي الألوان اليدوي
        if (_paletteMode == PaletteMode.preset)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip('RGB طيفي', 'rainbow'),
                _buildPresetChip('سايبربانك', 'cyberpunk'),
                _buildPresetChip('الشفق القطبي', 'aurora'),
                _buildPresetChip('نار وذهب', 'fire'),
                _buildPresetChip('فابورويف', 'vaporwave'),
              ],
            ),
          )
        else
          _buildCustomColorPickerWidget(),
      ],
    );
  }

  // أداة اختيار الألوان اليدوية
  Widget _buildCustomColorPickerWidget() {
    final List<Color> quickPalette = [
      const Color(0xFF00FFCC),
      const Color(0xFFFF0055),
      const Color(0xFF0088FF),
      const Color(0xFFFFCC00),
      const Color(0xFFAA00FF),
      const Color(0xFF00FF66),
      const Color(0xFFFF3300),
      const Color(0xFFFFFFFF),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_customColors.length, (index) {
            return Column(
              children: [
                Text('اللون ${index + 1}', style: const TextStyle(fontSize: 11, color: Colors.white60)),
                const SizedBox(height: 4),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _customColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _customColors[index].withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 10),
        // باليت الألوان السريعة للاختيار المباشر
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickPalette.map((col) {
              return GestureDetector(
                onTap: () {
                  _triggerHaptic();
                  setState(() {
                    _customColors[0] = col;
                    _customColors[1] = HSVColor.fromColor(col).withHue((HSVColor.fromColor(col).hue + 60) % 360).toColor();
                    _customColors[2] = HSVColor.fromColor(col).withHue((HSVColor.fromColor(col).hue + 140) % 360).toColor();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // التبويب 3: الحركة والإضاءة
  Widget _buildMotionAndGlowTab() {
    return Column(
      key: const ValueKey(2),
      children: [
        _buildSliderRow(
          title: 'سرعة التدرج',
          valueText: '${_speed.toStringAsFixed(1)}x',
          value: _speed,
          min: 0.1,
          max: 5.0,
          onChanged: (v) => setState(() => _speed = v),
        ),
        _buildSliderRow(
          title: 'كثافة وانتشار اللون',
          valueText: '${(_density * 100).toInt()}%',
          value: _density,
          min: 0.3,
          max: 3.0,
          onChanged: (v) => setState(() => _density = v),
        ),
        _buildSliderRow(
          title: 'شدة توهج النيون',
          valueText: '${(_glowIntensity * 100).toInt()}%',
          value: _glowIntensity,
          min: 0.0,
          max: 1.0,
          onChanged: (v) => setState(() => _glowIntensity = v),
        ),
        _buildSliderRow(
          title: 'سماكة الـ 3D (العمق)',
          valueText: '${_depthSlices.toInt()}',
          value: _depthSlices,
          min: 1.0,
          max: 16.0,
          onChanged: (v) => setState(() => _depthSlices = v),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF00FFCC)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssemblyChip(String label, AssemblyStyle style) {
    final isSelected = _currentAssemblyStyle == style;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF00FFCC),
        backgroundColor: Colors.white10,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          _triggerHaptic();
          setState(() => _currentAssemblyStyle = style);
          _replayAssembly();
        },
      ),
    );
  }

  Widget _buildGradientChip(String label, GradientMode mode) {
    final isSelected = _gradientMode == mode;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ChoiceChip(
          label: Center(child: Text(label)),
          selected: isSelected,
          selectedColor: const Color(0xFF00FFCC),
          backgroundColor: Colors.white10,
          labelStyle: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (_) {
            _triggerHaptic();
            setState(() => _gradientMode = mode);
          },
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String preset) {
    final isSelected = _presetName == preset;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF00FFCC),
        backgroundColor: Colors.white10,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          _triggerHaptic();
          setState(() => _presetName = preset);
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
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: GoogleFonts.tajawal(fontSize: 12, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {
                _triggerHaptic();
                onChanged(v);
              },
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              valueText,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFF00FFCC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسم الجزيئات النجمية الحركية بالخلفية
class ParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;

  ParticlesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rand = math.Random(1337);

    for (int i = 0; i < 45; i++) {
      final double x = rand.nextDouble() * size.width;
      final double initialY = rand.nextDouble() * size.height;
      final double speed = rand.nextDouble() * 0.35 + 0.1;
      final double y = (initialY + (progress * 120 * speed)) % size.height;
      final double radius = rand.nextDouble() * 1.8 + 0.5;
      final double alpha = (math.sin(progress * 6.28 + i) * 0.3 + 0.4).clamp(0.1, 0.7);

      paint.color = color.withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
