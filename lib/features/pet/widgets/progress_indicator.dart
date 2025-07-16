import 'package:flutter/material.dart';
import 'package:pet_app/l10n/app_localizations.dart';

class StatusIndicator extends StatelessWidget {
  final IconData icon;
  final int value;

  const StatusIndicator({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine color based on value
    Color getColor() {
      if (icon == Icons.restaurant) {
        if (value <= 2) return Colors.red; // Tokluk düşükse kırmızı
        if (value >= 8) return Colors.green; // Tokluk yüksekse yeşil
        if (value >= 5) return Colors.orange;
        return Colors.yellow;
      }
      if (value >= 8) return Colors.green;
      if (value >= 5) return Colors.orange;
      return Colors.red;
    }
    
    final color = getColor();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Progress Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getLabel(context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '$value/10',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value / 10,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Status Text
                Text(
                  _getStatusText(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getLabel(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (icon) {
      case Icons.restaurant:
        return loc.satiety;
      case Icons.favorite:
        return loc.happiness;
      case Icons.battery_charging_full:
        return loc.energy;
      case Icons.healing:
        return loc.maintenance;
      default:
        return loc.statusInfo;
    }
  }
  
  String _getStatusText(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (icon == Icons.restaurant) {
      if (value <= 2) return loc.critical;
      if (value >= 8) return loc.excellent;
      if (value >= 5) return loc.good;
      return loc.medium;
    }
    if (value >= 9) return loc.excellent;
    if (value >= 7) return loc.good;
    if (value >= 5) return loc.medium;
    if (value >= 3) return loc.low;
    return loc.critical;
  }
}
