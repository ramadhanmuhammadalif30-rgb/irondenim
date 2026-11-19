import 'package:flutter/material.dart';
import '../utils.dart';

/// Kartu dasar (latar gelap hangat, border tipis).
class Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14,
    this.color = kPanel,
    this.borderColor = kBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Tombol utama bergradasi emas.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = enabled ? kBlack : kMuted;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? kGoldGradient : null,
          color: enabled ? null : const Color(0xFF26231F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: kGold.withAlpha(55),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Garis hias emas dengan berlian kecil di tengah.
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line(bool toRight) => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: toRight ? Alignment.centerLeft : Alignment.centerRight,
                end: toRight ? Alignment.centerRight : Alignment.centerLeft,
                colors: [Colors.transparent, kGold.withAlpha(150)],
              ),
            ),
          ),
        );
    return Row(
      children: [
        line(true),
        const SizedBox(width: 10),
        Transform.rotate(
          angle: 0.785398,
          child: Container(width: 6, height: 6, color: kGold),
        ),
        const SizedBox(width: 10),
        line(false),
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color background;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = kGoldLight,
    this.background = const Color(0xCC0A0A0A),
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: CircleBorder(side: BorderSide(color: kGold.withAlpha(70))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Tag(this.text, {super.key, this.color = kGold, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kGold.withAlpha(120)),
                gradient: RadialGradient(
                  colors: [kGold.withAlpha(34), Colors.transparent],
                ),
              ),
              child: Icon(icon, size: 40, color: kGold),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: serif(size: 21, color: kGoldLight)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted, height: 1.45)),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 230,
                child: GoldButton(label: buttonLabel!, onPressed: onPressed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback? onPlus;

  const QtyStepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  Widget _btn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: onTap == null ? kBorder : kGold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPanel2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kGold.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onMinus),
          SizedBox(
            width: 26,
            child: Center(
              child: Text('$qty',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          _btn(Icons.add, onPlus),
        ],
      ),
    );
  }
}

class TabHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const TabHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: serif(size: 30, color: kGoldLight)),
                const SizedBox(height: 6),
                Container(
                  width: 34,
                  height: 2,
                  decoration: const BoxDecoration(gradient: kGoldGradient),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(subtitle!,
                        style: const TextStyle(color: kMuted, fontSize: 13)),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
                color: kGold,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: kBorder)),
        ],
      ),
    );
  }
}

/// Pil filter (Semua / Jeans / Jaket ...).
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? kGoldGradient : null,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? kGold : kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? kBlack : kCream,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              fontSize: 13),
        ),
      ),
    );
  }
}

/// Dialog konfirmasi bergaya sama dengan aplikasi.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  bool danger = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: kPanel2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: kGold.withAlpha(70)),
      ),
      title: Text(title, style: serif(size: 21, color: kGoldLight)),
      content: Text(message, style: const TextStyle(color: kMuted, height: 1.45)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal', style: TextStyle(color: kMuted)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: danger ? kDanger : kGold,
            foregroundColor: danger ? Colors.white : kBlack,
            minimumSize: const Size(88, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return r ?? false;
}
