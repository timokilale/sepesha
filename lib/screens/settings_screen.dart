import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/provider/localization_provider.dart';
import 'package:sepesha_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColor.white2,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.blackText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.settings,
          style: AppTextStyle.heading3(AppColor.blackText),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Settings Section
                _buildLanguageSection(localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: AppColor.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.languageSettings,
                        style: AppTextStyle.paragraph2(AppColor.blackText).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.selectLanguage,
                        style: AppTextStyle.subtext1(AppColor.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Language Options
          Consumer<LocalizationProvider>(
            builder: (context, localizationProvider, child) {
              return Column(
                children: [
                  _buildLanguageOption(
                    title: localizations.swahili,
                    subtitle: 'Kiswahili',
                    isSelected: localizationProvider.isSwahili,
                    onTap: () => _changeLanguage(const Locale('sw'), localizations),
                  ),
                  const Divider(height: 1),
                  _buildLanguageOption(
                    title: localizations.english,
                    subtitle: 'English',
                    isSelected: localizationProvider.isEnglish,
                    onTap: () => _changeLanguage(const Locale('en'), localizations),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 52), // Align with header content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.paragraph2(AppColor.blackText).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyle.subtext1(AppColor.grey),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColor.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeLanguage(Locale locale, AppLocalizations localizations) async {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    await localizationProvider.setLocale(locale);
    
    // Close loading dialog
    if (mounted) {
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.languageChanged),
          backgroundColor: const Color(0xFF008000), // SUCCESS color from memory
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
