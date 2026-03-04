import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/membership_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';

/// All memberships list with status filtering.
class MembershipsScreen extends ConsumerStatefulWidget {
  const MembershipsScreen({super.key});

  @override
  ConsumerState<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends ConsumerState<MembershipsScreen> {
  String _filter = 'all'; // all, active, expired, expiring

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(selectedGymProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.bgDark,
          toolbarHeight: 72,
          title: Text(
            'Memberships',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Filter chips
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          sliver: SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),
        ),

        // Membership list
        if (gym != null)
          _buildMembershipList(gym.id)
        else
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No gym selected',
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = {
      'all': 'All',
      'active': 'Active',
      'expiring': 'Expiring Soon',
      'expired': 'Expired',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          final isSelected = _filter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(entry.value),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              backgroundColor: AppColors.bgCard,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _filter = entry.key),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMembershipList(String gymId) {
    return FutureBuilder<List<Membership>>(
      future: ref.read(databaseServiceProvider).getMembershipsForGym(gymId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final allMemberships = snapshot.data ?? [];
        final filtered = _applyFilter(allMemberships);

        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_membership_outlined,
                      size: 56,
                      color: AppColors.textMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No memberships found',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MembershipCard(
                membership: filtered[index],
                delay: index * 50,
              ),
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }

  List<Membership> _applyFilter(List<Membership> memberships) {
    switch (_filter) {
      case 'active':
        return memberships
            .where((m) => m.status.value == 'active' && !m.isExpired)
            .toList();
      case 'expired':
        return memberships
            .where((m) => m.isExpired || m.status.value == 'expired')
            .toList();
      case 'expiring':
        return memberships.where((m) => m.expiresWithin(7)).toList();
      default:
        return memberships;
    }
  }
}

/// Membership card with status indicator.
class _MembershipCard extends StatelessWidget {
  final Membership membership;
  final int delay;

  const _MembershipCard({required this.membership, required this.delay});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.planName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${membership.startDate.shortFormatted} → ${membership.endDate.shortFormatted}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Amount & status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (membership.amount != null)
                Text(
                  membership.amount!.inr,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03, end: 0);
  }

  Color _getStatusColor() {
    if (membership.isExpired) return AppColors.error;
    if (membership.expiresWithin(7)) return AppColors.warning;
    return AppColors.success;
  }

  String _getStatusLabel() {
    if (membership.isExpired) return 'Expired';
    if (membership.expiresWithin(3)) return 'Expiring!';
    if (membership.expiresWithin(7)) return '${membership.daysRemaining}d left';
    return 'Active';
  }
}
