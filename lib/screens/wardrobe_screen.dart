import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String _selectedMode = 'comfort'; // 'comfort' or 'correction'
  String _selectedBodyPart = 'all';
  List<ClothingItem> _selectedItems = [];

  List<ClothingItem> _getComfortItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      ClothingItem(
        name: l10n.looseTshirt,
        category: 'top',
        comfortLevel: 9,
        correctionLevel: 2,
        description: l10n.looseTshirtDescription,
        icon: '👕',
      ),
      ClothingItem(
        name: l10n.looseJeans,
        category: 'bottom',
        comfortLevel: 8,
        correctionLevel: 3,
        description: l10n.looseJeansDescription,
        icon: '👖',
      ),
      ClothingItem(
        name: l10n.sportsShorts,
        category: 'bottom',
        comfortLevel: 10,
        correctionLevel: 1,
        description: l10n.sportsShortsDescription,
        icon: '🩳',
      ),
      ClothingItem(
        name: l10n.cottonShirt,
        category: 'top',
        comfortLevel: 7,
        correctionLevel: 4,
        description: l10n.cottonShirtDescription,
        icon: '👔',
      ),
    ];
  }

  List<ClothingItem> _getCorrectionItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      ClothingItem(
        name: l10n.compressionTank,
        category: 'top',
        comfortLevel: 4,
        correctionLevel: 9,
        description: l10n.compressionTankDescription,
        icon: '🎽',
      ),
      ClothingItem(
        name: l10n.compressionLeggings,
        category: 'bottom',
        comfortLevel: 6,
        correctionLevel: 8,
        description: l10n.compressionLeggingsDescription,
        icon: '🩱',
      ),
      ClothingItem(
        name: l10n.postureCorset,
        category: 'top',
        comfortLevel: 3,
        correctionLevel: 10,
        description: l10n.postureCorsetDescription,
        icon: '🦴',
      ),
      ClothingItem(
        name: l10n.sportsBra,
        category: 'top',
        comfortLevel: 7,
        correctionLevel: 7,
        description: l10n.sportsBraDescription,
        icon: '👙',
      ),
    ];
  }

  List<ClothingItem> get _currentItems {
    return _selectedMode == 'comfort' ? _getComfortItems(context) : _getCorrectionItems(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wardrobe),
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
            // Mode selector
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectFittingMode,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModeButton(
                          AppLocalizations.of(context)!.comfortMode,
                          AppLocalizations.of(context)!.maximumRelaxation,
                          Icons.sentiment_satisfied,
                          Colors.green,
                          'comfort',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModeButton(
                          AppLocalizations.of(context)!.correctionMode,
                          AppLocalizations.of(context)!.activeBodyWork,
                          Icons.fitness_center,
                          Colors.orange,
                          'correction',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body part selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bodyPart,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildBodyPartButton(AppLocalizations.of(context)!.allBodyParts, 'all', Icons.person),
                        _buildBodyPartButton(AppLocalizations.of(context)!.topClothing, 'top', Icons.accessibility),
                        _buildBodyPartButton(AppLocalizations.of(context)!.bottomClothing, 'bottom', Icons.directions_walk),
                        _buildBodyPartButton(AppLocalizations.of(context)!.shoes, 'shoes', Icons.sports_soccer),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Items list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMode == 'comfort' ? AppLocalizations.of(context)!.comfortableClothing : AppLocalizations.of(context)!.correctiveClothing,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _currentItems.length,
                        itemBuilder: (context, index) {
                          final item = _currentItems[index];
                          if (_selectedBodyPart != 'all' && item.category != _selectedBodyPart) {
                            return const SizedBox.shrink();
                          }
                          return _buildClothingItem(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selected items summary
            if (_selectedItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.selectedItems} (${_selectedItems.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _selectedItems.map((item) => Chip(
                        label: Text(item.name),
                        backgroundColor: Colors.deepPurple.shade300,
                        deleteIcon: const Icon(Icons.close, color: Colors.white),
                        onDeleted: () => _removeItem(item),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String mode,
  ) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
          _selectedItems.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyPartButton(String title, String part, IconData icon) {
    final isSelected = _selectedBodyPart == part;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBodyPart = part;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade300 : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItem(ClothingItem item) {
    final isSelected = _selectedItems.contains(item);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              item.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLevelIndicator(AppLocalizations.of(context)!.comfort, item.comfortLevel, Colors.green),
                const SizedBox(width: 16),
                _buildLevelIndicator(AppLocalizations.of(context)!.correction, item.correctionLevel, Colors.orange),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            color: isSelected ? Colors.green : Colors.white70,
          ),
          onPressed: () {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(item);
              } else {
                _selectedItems.add(item);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(String label, int level, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Row(
          children: List.generate(10, (index) => Container(
            width: 4,
            height: 8,
            margin: const EdgeInsets.only(right: 1),
            decoration: BoxDecoration(
              color: index < level ? color : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
        ),
      ],
    );
  }

  void _removeItem(ClothingItem item) {
    setState(() {
      _selectedItems.remove(item);
    });
  }
}

class ClothingItem {
  final String name;
  final String category;
  final int comfortLevel;
  final int correctionLevel;
  final String description;
  final String icon;

  ClothingItem({
    required this.name,
    required this.category,
    required this.comfortLevel,
    required this.correctionLevel,
    required this.description,
    required this.icon,
  });
} 