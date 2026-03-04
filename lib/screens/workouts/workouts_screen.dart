import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/enums.dart';
import '../../widgets/glassmorphic_card.dart';

/// Workout plan list + quick builder screen.
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  // Preview / template data
  final _templates = const [
    _PlanTemplate(
      name: 'PPL — Push Pull Legs',
      days: 6,
      goal: 'Muscle Gain',
      level: 'Intermediate',
      icon: Icons.fitness_center_rounded,
    ),
    _PlanTemplate(
      name: 'Upper/Lower Split',
      days: 4,
      goal: 'Strength',
      level: 'Intermediate',
      icon: Icons.sports_gymnastics_rounded,
    ),
    _PlanTemplate(
      name: 'Full Body 3x',
      days: 3,
      goal: 'General Fitness',
      level: 'Beginner',
      icon: Icons.accessibility_new_rounded,
    ),
    _PlanTemplate(
      name: 'Body Recomp',
      days: 5,
      goal: 'Fat Loss + Muscle',
      level: 'Advanced',
      icon: Icons.local_fire_department_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.bgDark,
          title: Text(
            'Workout Plans',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            FilledButton.icon(
              onPressed: _showCreatePlanSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Create Plan',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),

        // Templates section
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Quick Start Templates',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTemplateCard(_templates[index], index),
              childCount: _templates.length,
            ),
          ),
        ),

        // Recent plans
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Plans',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
        ),

        // Empty state
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 48,
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No workout plans yet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a plan manually or use a template to get started',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildTemplateCard(_PlanTemplate template, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creating ${template.name} plan…'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(template.icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildTag('${template.days}d/wk'),
                const SizedBox(width: 6),
                _buildTag(template.goal),
                const SizedBox(width: 6),
                _buildTag(template.level),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: (200 + index * 80).ms)
        .fadeIn()
        .slideY(begin: 0.08, end: 0);
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showCreatePlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreatePlanSheet(),
    );
  }
}

/// Bottom sheet for creating a new workout plan.
class _CreatePlanSheet extends StatefulWidget {
  @override
  State<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<_CreatePlanSheet> {
  final _nameController = TextEditingController();
  FitnessGoal _goal = FitnessGoal.generalFitness;
  int _durationWeeks = 8;
  int _daysPerWeek = 4;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Create Workout Plan',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Plan name
            TextFormField(
              controller: _nameController,
              style:
                  GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Plan Name',
                hintText: 'e.g., Hypertrophy Phase 1',
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Goal dropdown
            DropdownButtonFormField<FitnessGoal>(
              value: _goal,
              items: FitnessGoal.values
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g.label,
                            style: GoogleFonts.inter(
                                color: AppColors.textPrimary, fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _goal = v!),
              decoration: InputDecoration(
                labelText: 'Primary Goal',
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              dropdownColor: AppColors.bgElevated,
            ),
            const SizedBox(height: 16),

            // Duration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Row(
                        children: [4, 6, 8, 12]
                            .map((w) => Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _durationWeeks = w),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _durationWeeks == w
                                            ? AppColors.primary
                                                .withValues(alpha: 0.15)
                                            : AppColors.bgInput,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _durationWeeks == w
                                              ? AppColors.primary
                                              : AppColors.border,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${w}wk',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: _durationWeeks == w
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: _durationWeeks == w
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Days per week
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Training Days / Week',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(6, (i) {
                    final d = i + 2;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _daysPerWeek = d),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 5 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _daysPerWeek == d
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.bgInput,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _daysPerWeek == d
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$d',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: _daysPerWeek == d
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: _daysPerWeek == d
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Create button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Created "${_nameController.text}" — ${_daysPerWeek}d/wk, $_durationWeeks weeks'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Create Plan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.05, end: 0, duration: 300.ms).fadeIn();
  }
}

class _PlanTemplate {
  final String name;
  final int days;
  final String goal;
  final String level;
  final IconData icon;

  const _PlanTemplate({
    required this.name,
    required this.days,
    required this.goal,
    required this.level,
    required this.icon,
  });
}
