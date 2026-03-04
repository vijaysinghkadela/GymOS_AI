import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/client_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';
import 'add_client_screen.dart';
import 'client_detail_screen.dart';

/// Provider for filtered/searched client list.
final clientSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredClientsProvider =
    FutureProvider<List<ClientProfile>>((ref) async {
  final gym = ref.watch(selectedGymProvider);
  if (gym == null) return [];

  final db = ref.read(databaseServiceProvider);
  final clients = await db.getClientsForGym(gym.id);
  final query = ref.watch(clientSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return clients;

  return clients.where((c) {
    final name = (c.fullName ?? '').toLowerCase();
    final email = (c.email ?? '').toLowerCase();
    final phone = (c.phone ?? '').toLowerCase();
    return name.contains(query) ||
        email.contains(query) ||
        phone.contains(query);
  }).toList();
});

/// Client list screen with search, filters, and CRUD.
class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(filteredClientsProvider);

    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.bgDark,
          toolbarHeight: 72,
          title: Text(
            'Clients',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            // Client count badge
            if (clientsAsync.hasValue)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${clientsAsync.value!.length} clients',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            // Add client button
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => _showAddClientSheet(context),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text(
                  context.isMobile ? 'Add' : 'Add Client',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Search bar
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          sliver: SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
        ),

        // Client list
        clientsAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(
              child: Text(
                'Error loading clients: $error',
                style: GoogleFonts.inter(color: AppColors.error),
              ),
            ),
          ),
          data: (clients) {
            if (clients.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState());
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _ClientCard(
                      client: clients[index],
                      delay: index * 50,
                      onTap: () => _navigateToDetail(clients[index]),
                    );
                  },
                  childCount: clients.length,
                ),
              ),
            );
          },
        ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, email, or phone…',
          hintStyle:
              GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(clientSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          ref.read(clientSearchQueryProvider.notifier).state = value;
        },
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.people_outline_rounded,
                size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No clients yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first client to get started',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _showAddClientSheet(context),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: Text(
              'Add Client',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _showAddClientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddClientScreen(),
    );
  }

  void _navigateToDetail(ClientProfile client) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientDetailScreen(client: client),
      ),
    );
  }
}

/// Client list card with avatar, info, and status indicator.
class _ClientCard extends StatelessWidget {
  final ClientProfile client;
  final int delay;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName ?? 'Unnamed Client',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (client.email != null) ...[
                            Icon(Icons.email_outlined,
                                size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                client.email!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildTag(client.goal.label, AppColors.primary),
                          _buildTag(
                              client.trainingLevel.label, AppColors.accent),
                          if (client.dietType.label != 'Other')
                            _buildTag(client.dietType.label, AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03, end: 0);
  }

  Widget _buildAvatar() {
    final initial = (client.fullName?.isNotEmpty == true)
        ? client.fullName![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
