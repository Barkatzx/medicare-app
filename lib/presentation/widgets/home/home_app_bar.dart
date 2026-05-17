import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../domain/entities/address_entity.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProviderNotifier).loadUnreadCount();
      ref.read(addressProviderNotifier).loadAddresses();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  Color _getGreetingIconColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) return const Color(0xFFFBBF24);
    if (hour < 17) return const Color(0xFF60A5FA);
    return const Color(0xFF818CF8);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProviderNotifier).currentUser;
    final unreadCount = ref.watch(notificationProviderNotifier).unreadCount;
    final addresses = ref.watch(addressProviderNotifier).addresses;

    AddressEntity? defaultAddress;
    try {
      defaultAddress = addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      if (addresses.isNotEmpty) defaultAddress = addresses.first;
    }

    final initial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'G';
    final displayName = user?.name ?? 'Guest User';
    final locationText = defaultAddress != null
        ? '${defaultAddress.city}, ${defaultAddress.state}'
        : 'Add location';
    final hasLocation = defaultAddress != null;

    return AppBar(
      elevation: 0,
      toolbarHeight: 72,
      backgroundColor: CustomTheme.backgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor,
                      borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: CustomTextStyle.heading3.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  // Online dot
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: CustomTheme.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomTheme.backgroundColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Greeting + Name + Location ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Greeting row
                  Row(
                    children: [
                      Icon(
                        _getGreetingIcon(),
                        size: 13,
                        color: _getGreetingIconColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getGreeting(),
                        style: CustomTextStyle.caption.copyWith(
                          color: CustomTheme.textTertiary,
                          fontWeight: CustomTheme.fontWeightMedium,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  // Name
                  Text(
                    displayName,
                    style: CustomTextStyle.heading4.copyWith(
                      fontSize: 15,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Location chip
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasLocation
                              ? Icons.location_on_rounded
                              : Icons.add_location_alt_outlined,
                          size: 11,
                          color: hasLocation
                              ? CustomTheme.primaryColor
                              : CustomTheme.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            locationText,
                            style: CustomTextStyle.caption.copyWith(
                              color: hasLocation
                                  ? CustomTheme.textSecondary
                                  : CustomTheme.textTertiary,
                              fontWeight: hasLocation
                                  ? CustomTheme.fontWeightMedium
                                  : CustomTheme.fontWeightRegular,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!hasLocation) ...[
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 11,
                            color: CustomTheme.textTertiary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Action Buttons ────────────────────────────────────────
            _ActionButton(
              icon: Icons.search_rounded,
              onTap: () => Navigator.pushNamed(context, '/search'),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.notifications_rounded,
              badgeCount: unreadCount,
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          border: Border.all(color: CustomTheme.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: CustomTheme.textPrimary),
            if (badgeCount > 0)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: CustomTheme.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}