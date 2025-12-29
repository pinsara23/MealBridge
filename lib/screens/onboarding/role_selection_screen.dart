import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.03),
              Colors.white,
              AppColors.secondary.withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Title with icon
                Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_search_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Who are you?',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select your role to get started',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
              
                // Role Cards
                _RoleCard(
                  title: 'Donor',
                  description: 'I want to donate surplus food',
                  icon: Icons.volunteer_activism_rounded,
                  color: AppColors.donor,
                  onTap: () => _navigateToAuth(context, UserRole.donor),
                ),
                
                const SizedBox(height: 16),
                
                _RoleCard(
                  title: 'Recipient',
                  description: 'I need food assistance',
                  icon: Icons.person_rounded,
                  color: AppColors.recipient,
                  onTap: () => _navigateToAuth(context, UserRole.recipient),
                ),
                
                const SizedBox(height: 16),
                
                _RoleCard(
                  title: 'Volunteer',
                  description: 'I want to help deliver food',
                  icon: Icons.directions_bike_rounded,
                  color: AppColors.volunteer,
                  onTap: () => _navigateToAuth(context, UserRole.volunteer),
                ),
                
                const SizedBox(height: 16),
                
                _RoleCard(
                  title: 'Admin',
                  description: 'Manage and monitor operations',
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppColors.admin,
                  onTap: () => _navigateToAuth(context, UserRole.admin),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, UserRole role) {
    Navigator.pushNamed(context, AppRoutes.login, arguments: role);
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(0.15),
                      widget.color.withOpacity(0.05),
                    ],
                  )
                : null,
            color: _isHovered ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? widget.color : AppColors.border,
              width: _isHovered ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? widget.color.withOpacity(0.25) : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: _isHovered
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [widget.color, widget.color.withOpacity(0.7)],
                        )
                      : null,
                  color: _isHovered ? null : widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  widget.icon,
                  size: 36,
                  color: _isHovered ? Colors.white : widget.color,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _isHovered ? widget.color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Animated Arrow
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isHovered ? 0 : -0.125,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.color,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
