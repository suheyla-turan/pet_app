import 'package:flutter/material.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Track expanded states for each category and question
  final Map<int, bool> _categoryExpanded = {};
  final Map<String, bool> _questionExpanded = {};
  
  // FAQ Categories
  List<FAQCategory> _getFAQCategories(AppLocalizations l10n) {
    return [
      FAQCategory(
        title: l10n.faqGeneral,
        icon: Icons.help_outline,
        color: Colors.blue,
        questions: [
          FAQItem(
            question: l10n.faqWhatIsPatiTakip,
            answer: l10n.faqWhatIsPatiTakipAnswer,
          ),
          FAQItem(
            question: l10n.faqHowToAddPet,
            answer: l10n.faqHowToAddPetAnswer,
          ),
          FAQItem(
            question: l10n.faqMultiplePets,
            answer: l10n.faqMultiplePetsAnswer,
          ),
        ],
      ),
      FAQCategory(
        title: l10n.faqFeatures,
        icon: Icons.star,
        color: Colors.orange,
        questions: [
          FAQItem(
            question: l10n.faqHowToTrackVaccines,
            answer: l10n.faqHowToTrackVaccinesAnswer,
          ),
          FAQItem(
            question: l10n.faqHowToUseAI,
            answer: l10n.faqHowToUseAIAnswer,
          ),
          FAQItem(
            question: l10n.faqVoiceCommands,
            answer: l10n.faqVoiceCommandsAnswer,
          ),
          FAQItem(
            question: l10n.faqNotifications,
            answer: l10n.faqNotificationsAnswer,
          ),
        ],
      ),
      FAQCategory(
        title: l10n.faqTechnical,
        icon: Icons.settings,
        color: Colors.green,
        questions: [
          FAQItem(
            question: l10n.faqDataBackup,
            answer: l10n.faqDataBackupAnswer,
          ),
          FAQItem(
            question: l10n.faqAppUpdates,
            answer: l10n.faqAppUpdatesAnswer,
          ),
          FAQItem(
            question: l10n.faqShareAccount,
            answer: l10n.faqShareAccountAnswer,
          ),
        ],
      ),
      FAQCategory(
        title: l10n.faqSupport,
        icon: Icons.support_agent,
        color: Colors.purple,
        questions: [
          FAQItem(
            question: l10n.faqContactSupport,
            answer: l10n.faqContactSupportAnswer,
          ),
          FAQItem(
            question: l10n.faqPrivacyPolicy,
            answer: l10n.faqPrivacyPolicyAnswer,
          ),
          FAQItem(
            question: l10n.faqTermsOfService,
            answer: l10n.faqTermsOfServiceAnswer,
          ),
        ],
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  const Color(0xFF1A202C),
                  const Color(0xFF2D3748),
                  const Color(0xFF4A5568),
                ]
              : [
                  const Color(0xFFF7FAFC),
                  const Color(0xFFEDF2F7),
                  const Color(0xFFE2E8F0),
                ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Beautiful Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            l10n.faqTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            l10n.faqDescription,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // FAQ Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: bottomPadding + 20,
                    ),
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Soru ara...',
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        
                        // FAQ Categories using ExpansionPanel
                        _buildFAQExpansionPanel(l10n),
                        
                        const SizedBox(height: 30),
                        
                        // Contact Support Section
                        _buildContactSupportSection(l10n),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQExpansionPanel(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final faqCategories = _getFAQCategories(l10n);
    
    return ExpansionPanelList(
      elevation: 8,
      expandedHeaderPadding: const EdgeInsets.all(16),
      expansionCallback: (int panelIndex, bool isExpanded) {
        setState(() {
          _categoryExpanded[panelIndex] = !isExpanded;
        });
      },
      children: faqCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isExpanded = _categoryExpanded[index] ?? false;
        
        return ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          body: Column(
            children: category.questions.map((faq) => _buildFAQItem(faq)).toList(),
          ),
          isExpanded: isExpanded,
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final questionKey = faq.question;
    final isExpanded = _questionExpanded[questionKey] ?? false;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _questionExpanded[questionKey] = expanded;
          });
        },
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 8,
      shadowColor: Colors.purple.withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey.shade800,
                    Colors.grey.shade700,
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hala yardıma mı ihtiyacınız var?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          'Destek ekibimizle iletişime geçin',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Contact Options
              Row(
                children: [
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.email,
                      label: 'E-posta',
                      color: Colors.blue,
                      onTap: () => _launchEmail(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.feedback,
                      label: 'Geri Bildirim',
                      color: Colors.green,
                      onTap: () => _navigateToFeedback(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeedback() {
    Navigator.pop(context);
  }

  void _launchEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Gönder'),
        content: const Text('E-posta uygulamanız açılacak ve info@patitakip.com adresine mesaj gönderebileceksiniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class FAQCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<FAQItem> questions;

  FAQCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
} 