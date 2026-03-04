import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/subscription_banner.dart';
import '../clients/clients_screen.dart';
import '../memberships/memberships_screen.dart';
import '../subscription/pricing_screen.dart';
import '../workouts/workouts_screen.dart';
import '../diet/diet_plans_screen.dart';
import '../settings/settings_screen.dart';

/// Main dashboard screen with responsive layout.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedNavIndex = 0;

  final _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.people_rounded, label: 'Clients'),
    _NavItem(icon: Icons.card_membership_rounded, label: 'Memberships'),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Workouts'),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Diet Plans'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      // Mobile bottom nav
      bottomNavigationBar: (!isDesktop && !isTablet) ? _buildBottomNav() : null,
      body: Row(
        children: [
          // Desktop sidebar
          if (isDesktop || isTablet)
            SidebarNav(
              items: _navItems
                  .map((n) => SidebarItem(
                        icon: n.icon,
                        label: n.label,
                      ))
                  .toList(),
              selectedIndex: _selectedNavIndex,
              onItemTap: (i) => setState(() => _selectedNavIndex = i),
              isCollapsed: isTablet,
              userName: currentUser.value?.fullName ?? 'User',
              userEmail: currentUser.value?.email ?? '',
              onSignOut: () async {
                final router = GoRouter.of(context);
                await ref.read(currentUserProvider.notifier).signOut();
                if (mounted) router.go('/login');
              },
            ),

          // Main content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const ClientsScreen();
      case 2:
        return const MembershipsScreen();
      case 3:
        return const WorkoutsScreen();
      case 4:
        return const DietPlansScreen();
      case 5:
        return const SettingsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    final gym = ref.watch(selectedGymProvider);
    final stats = ref.watch(dashboardStatsProvider);

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.bgDark,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gym?.name ?? 'Your Gym',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Dashboard Overview',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textSecondary),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Subscription banner
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: SubscriptionBanner(
              onUpgrade: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PricingScreen(),
                  ),
                );
              },
            ),
          ),
        ),

        // Stats grid
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: _buildStatsGrid(stats),
          ),
        ),

        // Quick Actions
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _buildQuickActions(),
          ),
        ),

        // Recent activity
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: _buildRecentActivity(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AsyncValue<Map<String, dynamic>> stats) {
    final statsData = stats.value ?? {};

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 500
                ? 2
                : 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: (constraints.maxWidth - 16 * (crossAxisCount - 1)) /
                  crossAxisCount,
              child: StatCard(
                title: 'Total Clients',
                value: '${statsData['total_clients'] ?? 0}',
                icon: Icons.people_rounded,
                color: AppColors.primary,
                delay: 0,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 16 * (crossAxisCount - 1)) /
                  crossAxisCount,
              child: StatCard(
                title: 'Active Members',
                value: '${statsData['active_members'] ?? 0}',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                delay: 100,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 16 * (crossAxisCount - 1)) /
                  crossAxisCount,
              child: StatCard(
                title: 'Expired',
                value: '${statsData['expired_members'] ?? 0}',
                icon: Icons.cancel_rounded,
                color: AppColors.error,
                delay: 200,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 16 * (crossAxisCount - 1)) /
                  crossAxisCount,
              child: StatCard(
                title: 'Expiring Soon',
                value: '${statsData['expiring_soon'] ?? 0}',
                icon: Icons.warning_rounded,
                color: AppColors.warning,
                delay: 300,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: Icons.person_add_rounded,
              label: 'Add Client',
              color: AppColors.primary,
              onTap: () => setState(() => _selectedNavIndex = 1),
            ),
            _QuickActionButton(
              icon: Icons.card_membership_rounded,
              label: 'New Membership',
              color: AppColors.accent,
              onTap: () => setState(() => _selectedNavIndex = 2),
            ),
            _QuickActionButton(
              icon: Icons.auto_awesome,
              label: 'AI Plan',
              color: AppColors.warning,
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.attach_money_rounded,
              label: 'Pricing',
              color: AppColors.info,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PricingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No activity yet',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start by adding your first client',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex > 3 ? 0 : _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
        items: _navItems.take(4).map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Quick action button.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple nav item data.
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
