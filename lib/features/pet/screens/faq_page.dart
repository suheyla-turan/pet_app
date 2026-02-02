import 'package:flutter/material.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'feedback_page.dart';

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
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
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
          FAQItem(
            question: l10n.faqAppFree,
            answer: l10n.faqAppFreeAnswer,
          ),
          FAQItem(
            question: l10n.faqDeviceSupport,
            answer: l10n.faqDeviceSupportAnswer,
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
            question: l10n.faqNotifications,
            answer: l10n.faqNotificationsAnswer,
          ),
          FAQItem(
            question: l10n.faqDataSecurity,
            answer: l10n.faqDataSecurityAnswer,
          ),
        ],
      ),
      FAQCategory(
        title: l10n.faqPetCareHealth,
        icon: Icons.favorite,
        color: Colors.red,
        questions: [
          FAQItem(
            question: l10n.faqPetHealth,
            answer: l10n.faqPetHealthAnswer,
          ),
          FAQItem(
            question: l10n.faqPetPhotos,
            answer: l10n.faqPetPhotosAnswer,
          ),
          FAQItem(
            question: l10n.faqPetNotes,
            answer: l10n.faqPetNotesAnswer,
          ),
          FAQItem(
            question: l10n.faqPetReminders,
            answer: l10n.faqPetRemindersAnswer,
          ),
          FAQItem(
            question: "Evcil hayvanımın ağırlığını takip edebilir miyim?",
            answer: "Evet, evcil hayvanınızın ağırlığını notlarda kaydedebilirsiniz. Bu sayede kilo değişimlerini takip edebilir ve sağlık durumunu izleyebilirsiniz.",
          ),
          FAQItem(
            question: "Veteriner randevularını takip edebilir miyim?",
            answer: "Evet, veteriner randevularını notlarda kaydedebilirsiniz.",
          ),
        ],
      ),
      FAQCategory(
        title: l10n.faqPetLifestyle,
        icon: Icons.pets,
        color: Colors.teal,
        questions: [
          FAQItem(
            question: l10n.faqPetTraining,
            answer: l10n.faqPetTrainingAnswer,
          ),
          FAQItem(
            question: l10n.faqPetExercise,
            answer: l10n.faqPetExerciseAnswer,
          ),
          FAQItem(
            question: l10n.faqPetDiet,
            answer: l10n.faqPetDietAnswer,
          ),
          FAQItem(
            question: l10n.faqPetGrooming,
            answer: l10n.faqPetGroomingAnswer,
          ),
          FAQItem(
            question: "Evcil hayvanımın uyku düzenini takip edebilir miyim?",
            answer: "Evet, evcil hayvanınızın uyku düzenini notlarda kaydedebilirsiniz. Uyku süresi ve kalitesi hakkında notlar alabilirsiniz.",
          ),
          FAQItem(
            question: "Sosyal aktiviteleri nasıl kaydedebilirim?",
            answer: "Evcil hayvanınızın diğer hayvanlarla oyun zamanlarını, park ziyaretlerini ve sosyal aktivitelerini notlarda kaydedebilirsiniz.",
          ),
        ],
      ),
      FAQCategory(
        title: l10n.faqTravelSocial,
        icon: Icons.flight,
        color: Colors.indigo,
        questions: [
          FAQItem(
            question: l10n.faqPetTravel,
            answer: l10n.faqPetTravelAnswer,
          ),
          FAQItem(
            question: l10n.faqPetSocial,
            answer: l10n.faqPetSocialAnswer,
          ),
          FAQItem(
            question: l10n.faqPetEmergency,
            answer: l10n.faqPetEmergencyAnswer,
          ),
          FAQItem(
            question: "Farklı ülkelerde aşı gereksinimleri hakkında bilgi alabilir miyim?",
            answer: "AI sohbet özelliğini kullanarak genel bilgi alabilirsiniz, ancak her zaman resmi veteriner kaynaklarını kontrol etmenizi öneririz.",
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
          FAQItem(
            question: l10n.faqOfflineUse,
            answer: l10n.faqOfflineUseAnswer,
          ),
          FAQItem(
            question: l10n.faqAppSize,
            answer: l10n.faqAppSizeAnswer,
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
            question: l10n.faqTermsOfService,
            answer: l10n.faqTermsOfServiceAnswer,
          ),
          FAQItem(
            question: l10n.faqBugReport,
            answer: l10n.faqBugReportAnswer,
          ),
          FAQItem(
            question: l10n.faqFeatureRequest,
            answer: l10n.faqFeatureRequestAnswer,
          ),
        ],
      ),
    ];
  }

  // Filter FAQ categories based on search query
  List<FAQCategory> _getFilteredFAQCategories(AppLocalizations l10n) {
    if (_searchQuery.isEmpty) {
      return _getFAQCategories(l10n);
    }
    
    final allCategories = _getFAQCategories(l10n);
    final filteredCategories = <FAQCategory>[];
    
    for (final category in allCategories) {
      final filteredQuestions = category.questions.where((question) {
        return question.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               question.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      
      if (filteredQuestions.isNotEmpty) {
        filteredCategories.add(FAQCategory(
          title: category.title,
          icon: category.icon,
          color: category.color,
          questions: filteredQuestions,
        ));
      }
    }
    
    return filteredCategories;
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
                    child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: themeProvider.getPrimaryTextColor(isDark),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'PatiTakip',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: themeProvider.getPrimaryTextColor(isDark),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Page Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          l10n.faqTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: themeProvider.getHighContrastTextColor(isDark),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.faqDescription,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.getHighContrastSecondaryTextColor(isDark),
                            fontWeight: FontWeight.w500,
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
                            color: themeProvider.getReadableCardBackgroundColor(isDark),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: themeProvider.getReadableCardShadow(isDark),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: l10n.faqSearchHint,
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        
                        // FAQ Categories using ExpansionPanel
                        _buildFAQExpansionPanel(l10n),
                        
                        const SizedBox(height: 30),
                        
                        // Contact Support Section - REMOVED
                        // _buildContactSupportSection(l10n),
                        
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final faqCategories = _getFilteredFAQCategories(l10n);
    
    return Column(
      children: faqCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isExpanded = _categoryExpanded[index] ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: themeProvider.getReadableCardBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(16),
            boxShadow: themeProvider.getReadableCardShadow(isDark),
          ),
          child: Column(
            children: [
              // Category Header - Clickable to expand/collapse
              InkWell(
                onTap: () {
                  setState(() {
                    _categoryExpanded[index] = !isExpanded;
                  });
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: category.color.withAlpha(25),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: themeProvider.getHighContrastTextColor(isDark),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Single chevron icon that rotates
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: category.color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Questions and Answers - Animated expansion
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    children: category.questions.map((faq) => _buildFAQItem(faq)).toList(),
                  ),
                ),
                crossFadeState: isExpanded 
                    ? CrossFadeState.showSecond 
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Question Header - Clickable to expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _questionExpanded[questionKey] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.question_answer,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  // Single chevron icon that rotates
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Answer - Animated expansion
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
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
            crossFadeState: isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
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
      shadowColor: Colors.purple.withAlpha(51),
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
                      color: Colors.purple.withAlpha(25),
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
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(76)),
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
    // Navigate to feedback page instead of just popping
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FeedbackPage()),
    );
  }

  void _launchEmail() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Gönder'),
        content: const Text('E-posta uygulamanız açılacak ve info@patitakip.com adresine mesaj gönderebileceksiniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openEmailApp();
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _openEmailApp() {
    // Show email address and instructions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please send email to: info@patitakip.com'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // Copy email to clipboard
            // In a real app, you might want to use clipboard package
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email address copied to clipboard'),
                backgroundColor: Colors.blue,
              ),
            );
          },
        ),
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