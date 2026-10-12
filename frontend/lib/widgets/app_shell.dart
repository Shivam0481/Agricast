import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';

class AppShell extends StatelessWidget {
  final AppScreen currentScreen;
  final Widget child;

  const AppShell({super.key, required this.currentScreen, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: AgriCastTheme.surface,
      body: isWide ? _WideLayout(current: currentScreen, child: child)
                   : _NarrowLayout(current: currentScreen, child: child),
    );
  }
}

class _NavItem {
  final AppScreen screen;
  final IconData icon;
  final String label;
  const _NavItem(this.screen, this.icon, this.label);
}

const _navItems = [
  _NavItem(AppScreen.dashboard, Icons.bar_chart_rounded, 'Dashboard'),
  _NavItem(AppScreen.scenario, Icons.tune_rounded, 'Scenario Analysis'),
  _NavItem(AppScreen.analytics, Icons.analytics_outlined, 'District Analytics'),
  _NavItem(AppScreen.reports, Icons.picture_as_pdf_outlined, 'PDF Reports'),
  _NavItem(AppScreen.about, Icons.info_outline_rounded, 'About'),
];

class _WideLayout extends StatelessWidget {
  final AppScreen current;
  final Widget child;
  const _WideLayout({required this.current, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Sidebar(current: current),
        Expanded(
          child: Column(
            children: [
              _TopBar(),
              Expanded(
                child: ClipRect(child: child),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  final AppScreen current;
  const _Sidebar({required this.current});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Container(
      width: 240,
      color: AgriCastTheme.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AgriCastTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('AgriCAST',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Crop Recommendation AI',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _navItems.map((item) => _SidebarTile(
                item: item,
                isSelected: current == item.screen,
                onTap: () => state.navigateTo(item.screen),
              )).toList(),
            ),
          ),
          // Bottom section
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AgriCastTheme.primaryDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model: LambdaMART v1',
                    style: GoogleFonts.inter(
                        color: AgriCastTheme.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('95 features · 300 trees',
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.45), fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GestureDetector(
              onTap: () => state.navigateTo(AppScreen.landing),
              child: Row(
                children: [
                  Icon(Icons.home_outlined, size: 16,
                      color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Text('Back to Home',
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _SidebarTile({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected
            ? AgriCastTheme.primary.withValues(alpha: 0.85)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(item.icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Text(item.label,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rec = state.recommendation;
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AgriCastTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (rec != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AgriCastTheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AgriCastTheme.borderGreen),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: AgriCastTheme.primaryMed),
                  const SizedBox(width: 4),
                  Text('${rec.districtName}, ${rec.stateName}  ·  ${rec.year}',
                      style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textGreen,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          const Spacer(),
          _ModelStatusBadge(),
        ],
      ),
    );
  }
}

class _ModelStatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rec = context.watch<AppState>().recommendation;
    final loaded = rec?.modelLoaded ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: loaded ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: loaded ? AgriCastTheme.accent : const Color(0xFFD97706),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(loaded ? 'Model Active' : 'Model Offline',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: loaded ? AgriCastTheme.primaryDark : const Color(0xFF92400E),
              )),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final AppScreen current;
  final Widget child;
  const _NarrowLayout({required this.current, required this.child});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.eco_rounded, color: AgriCastTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('AgriCAST',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AgriCastTheme.border),
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navItems.indexWhere((i) => i.screen == current).clamp(0, 4),
        onDestinationSelected: (i) => state.navigateTo(_navItems[i].screen),
        backgroundColor: Colors.white,
        indicatorColor: AgriCastTheme.divider,
        destinations: _navItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          label: item.label.split(' ').first,
        )).toList(),
      ),
    );
  }
}
