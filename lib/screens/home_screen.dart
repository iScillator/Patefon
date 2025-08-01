import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/localization_service.dart';
import 'anatomy_screen.dart';
import 'wardrobe_screen.dart';
import 'experiment_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final LocalizationService localizationService;
  
  const HomeScreen({super.key, required this.localizationService});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: l10n.language,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.welcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      l10n.anatomy,
                      Icons.science,
                      l10n.anatomyDescription,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnatomyScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      l10n.wardrobe,
                      Icons.checkroom,
                      l10n.wardrobeDescription,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WardrobeScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      l10n.experiment,
                      Icons.fitness_center,
                      l10n.experimentDescription,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExperimentScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      l10n.profile,
                      Icons.person,
                      l10n.profileDescription,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
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

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.deepPurple.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback если локализация недоступна
      return;
    }
    
    final currentLanguage = localizationService.getCurrentLanguageCode();
    final availableLanguages = localizationService.getAvailableLanguages();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableLanguages.length,
              itemBuilder: (context, index) {
                final language = availableLanguages[index];
                final languageCode = language['code'] ?? '';
                final languageName = language['name'] ?? 'Unknown';
                
                final isSelected = languageCode == currentLanguage || 
                                 (languageCode == 'system' && localizationService.isSystemLanguage);
                
                return ListTile(
                  title: Text(languageName),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.deepPurple) : null,
                  onTap: () {
                    if (languageCode.isNotEmpty) {
                      localizationService.setLanguage(languageCode);
                    }
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
} 