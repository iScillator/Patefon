import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnatomyScreen extends StatefulWidget {
  const AnatomyScreen({super.key});

  @override
  State<AnatomyScreen> createState() => _AnatomyScreenState();
}

class _AnatomyScreenState extends State<AnatomyScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;

  List<AnatomyStep> _getSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      AnatomyStep(
        title: l10n.anatomyStep1Title,
        description: l10n.anatomyStep1Description,
        icon: Icons.face,
        color: Colors.orange,
      ),
      AnatomyStep(
        title: l10n.anatomyStep2Title,
        description: l10n.anatomyStep2Description,
        icon: Icons.psychology,
        color: Colors.red,
      ),
      AnatomyStep(
        title: l10n.anatomyStep3Title,
        description: l10n.anatomyStep3Description,
        icon: Icons.view_in_ar,
        color: Colors.blue,
      ),
      AnatomyStep(
        title: l10n.anatomyStep4Title,
        description: l10n.anatomyStep4Description,
        icon: Icons.accessibility_new,
        color: Colors.green,
      ),
      AnatomyStep(
        title: l10n.anatomyStep5Title,
        description: l10n.anatomyStep5Description,
        icon: Icons.lightbulb,
        color: Colors.purple,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final steps = _getSteps(context);
    if (_currentStep < steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.anatomy),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / _getSteps(context).length,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSteps(context)[_currentStep].color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Step indicator
                    Text(
                      '${l10n.step} ${_currentStep + 1} ${l10n.ofLabel} ${_getSteps(context).length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Current step content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildStepContent(_getSteps(context)[_currentStep]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentStep > 0 ? _previousStep : null,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentStep < _getSteps(context).length - 1 ? _nextStep : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.next),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getSteps(context)[_currentStep].color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AnatomyStep step) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: step.color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: step.color,
              width: 3,
            ),
          ),
          child: Icon(
            step.icon,
            size: 60,
            color: step.color,
          ),
        ),
        const SizedBox(height: 30),
        
        // Title
        Text(
          step.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Description
        Text(
          step.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Interactive elements for specific steps
        if (_currentStep == 0) ...[
          const SizedBox(height: 30),
          _buildHairFollicleDemo(),
        ] else if (_currentStep == 1) ...[
          const SizedBox(height: 30),
          _buildNerveEndingsDemo(),
        ] else if (_currentStep == 4) ...[
          const SizedBox(height: 30),
          _buildExamplesDemo(),
        ],
      ],
    );
  }

  Widget _buildHairFollicleDemo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            l10n.interactiveHairModel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFolliclePart(l10n.bulb, Colors.orange),
              _buildFolliclePart(l10n.roots, Colors.brown),
              _buildFolliclePart(l10n.hair, Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFolliclePart(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNerveEndingsDemo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            l10n.nerveHairConnection,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNerveConnection(l10n.nerve, Colors.red),
              const Icon(Icons.arrow_forward, color: Colors.white70),
              _buildNerveConnection(l10n.hair, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNerveConnection(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExamplesDemo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            l10n.adaptationExamples,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildExample(l10n.watermelon, '🍉', l10n.cube, '⬜'),
              _buildExample(l10n.foot, '🦶', l10n.tightShoes, '👟'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExample(String before, String beforeIcon, String after, String afterIcon) {
    return Column(
      children: [
        Text(
          before,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(beforeIcon, style: const TextStyle(fontSize: 24)),
        const Icon(Icons.arrow_downward, color: Colors.white70, size: 16),
        Text(
          after,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(afterIcon, style: const TextStyle(fontSize: 24)),
      ],
    );
  }
}

class AnatomyStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  AnatomyStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
} 