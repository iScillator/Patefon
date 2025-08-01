import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExperimentScreen extends StatefulWidget {
  const ExperimentScreen({super.key});

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isExperimentActive = false;
  int _currentDay = 0;
  int _totalDays = 30;
  double _muscleProgress = 0.0;
  List<ExperimentDay> _experimentDays = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _initializeExperiment();
  }

  void _initializeExperiment() {
    _experimentDays = List.generate(_totalDays, (index) => ExperimentDay(
      day: index + 1,
      isCompleted: false,
      clothingRecommendations: _getClothingForDay(index + 1),
      notes: '',
    ));
  }

  List<String> _getClothingForDay(int day) {
    final l10n = AppLocalizations.of(context)!;
    if (day <= 7) {
      return [l10n.compressionTank, l10n.compressionLeggings];
    } else if (day <= 14) {
      return [l10n.sportsBra, l10n.compressionTank, l10n.compressionLeggings];
    } else if (day <= 21) {
      return [l10n.postureCorset, l10n.compressionTank, l10n.compressionLeggings];
    } else {
      return [l10n.postureCorset, l10n.compressionTank, l10n.compressionLeggings, l10n.sportsBra];
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startExperiment() {
    setState(() {
      _isExperimentActive = true;
      _currentDay = 1;
    });
    _animationController.forward();
  }

  void _completeDay() {
    if (_currentDay <= _totalDays) {
      setState(() {
        _experimentDays[_currentDay - 1].isCompleted = true;
        _muscleProgress = _currentDay / _totalDays;
        if (_currentDay < _totalDays) {
          _currentDay++;
        }
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.experiment),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Experiment overview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.experimentTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.experimentGoal,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    if (!_isExperimentActive) ...[
                      ElevatedButton.icon(
                        onPressed: _startExperiment,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(AppLocalizations.of(context)!.startExperiment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ] else ...[
                      _buildProgressSection(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Current day details
              if (_isExperimentActive) ...[
                Expanded(
                  child: _buildCurrentDayDetails(),
                ),
              ] else ...[
                Expanded(
                  child: _buildExperimentInfo(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppLocalizations.of(context)!.day} $_currentDay ${AppLocalizations.of(context)!.ofLabel} $_totalDays',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${(_muscleProgress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _muscleProgress,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _currentDay <= _totalDays ? _completeDay : null,
          icon: const Icon(Icons.check),
          label: Text(AppLocalizations.of(context)!.completeDay),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentDayDetails() {
    final currentDayData = _experimentDays[_currentDay - 1];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.of(context)!.day} $_currentDay',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            AppLocalizations.of(context)!.recommendedClothing,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...currentDayData.clothingRecommendations.map((clothing) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  clothing,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 20),
          
          Text(
            AppLocalizations.of(context)!.expectedEffect,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildExpectedEffect(),
          
          const SizedBox(height: 20),
          
          Text(
            AppLocalizations.of(context)!.notes,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.writeObservations,
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
            ),
            maxLines: 3,
            onChanged: (value) {
              currentDayData.notes = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpectedEffect() {
    final l10n = AppLocalizations.of(context)!;
    String effect;
    Color color;
    
    if (_currentDay <= 7) {
      effect = l10n.initialAdaptation;
      color = Colors.blue;
    } else if (_currentDay <= 14) {
      effect = l10n.improvedCirculation;
      color = Colors.green;
    } else if (_currentDay <= 21) {
      effect = l10n.nerveActivation;
      color = Colors.orange;
    } else {
      effect = l10n.maximumStimulation;
      color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        effect,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExperimentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.howItWorks,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoStep(
            1,
            AppLocalizations.of(context)!.step1Description,
            Icons.compress,
          ),
          _buildInfoStep(
            2,
            AppLocalizations.of(context)!.step2Description,
            Icons.psychology,
          ),
          _buildInfoStep(
            3,
            AppLocalizations.of(context)!.step3Description,
            Icons.accessibility_new,
          ),
          _buildInfoStep(
            4,
            AppLocalizations.of(context)!.step4Description,
            Icons.fitness_center,
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.important,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.experimentWarning,
                  style: TextStyle(color: Colors.orange.shade200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep(int number, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Icon(icon, color: Colors.deepPurple.shade300),
        ],
      ),
    );
  }
}

class ExperimentDay {
  final int day;
  bool isCompleted;
  final List<String> clothingRecommendations;
  String notes;

  ExperimentDay({
    required this.day,
    required this.isCompleted,
    required this.clothingRecommendations,
    required this.notes,
  });
} 