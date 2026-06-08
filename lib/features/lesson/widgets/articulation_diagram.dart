import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Schéma (coupe sagittale) de l'appareil phonatoire — profil tourné vers la
/// gauche : lèvres à gauche, gorge descendant à droite. Un point d'articulation
/// optionnel est mis en surbrillance (pulsation) à des coordonnées normalisées.
class ArticulationDiagram extends StatefulWidget {
  const ArticulationDiagram({
    super.key,
    this.pointX,
    this.pointY,
    this.zoneLabel,
  });

  /// Coordonnées normalisées (0..1) du point à mettre en avant.
  final double? pointX;
  final double? pointY;
  final String? zoneLabel;

  @override
  State<ArticulationDiagram> createState() => _ArticulationDiagramState();
}

class _ArticulationDiagramState extends State<ArticulationDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPoint = widget.pointX != null && widget.pointY != null;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _VocalTractPainter()),
            ),
            if (hasPoint)
              Align(
                alignment: Alignment(
                  widget.pointX! * 2 - 1,
                  widget.pointY! * 2 - 1,
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => _Highlight(t: _controller.value),
                ),
              ),
            if (widget.zoneLabel != null)
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.heart,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.zoneLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cercle de surbrillance pulsant (anneau + point plein).
class _Highlight extends StatelessWidget {
  const _Highlight({required this.t});

  /// Progression d'animation 0..1.
  final double t;

  @override
  Widget build(BuildContext context) {
    final ring = 18.0 + t * 22.0; // l'anneau grandit
    final opacity = (1 - t).clamp(0.0, 1.0);
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: ring,
            height: ring,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.heart.withOpacity(opacity),
                width: 3,
              ),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppTheme.heart,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dessine l'anatomie : cavité nasale, palais, langue, lèvres, et le conduit
/// de la gorge (pharynx) où s'articulent les lettres gutturales.
class _VocalTractPainter extends CustomPainter {
  const _VocalTractPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);

    // --- Conduit aérien (bouche + pharynx) : un large tracé clair. ---
    final airway = Paint()
      ..color = const Color(0xFFD6ECF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.14
      ..strokeCap = StrokeCap.round;
    final airwayPath = Path()
      ..moveTo(p(0.10, 0.45).dx, p(0.10, 0.45).dy)
      ..lineTo(p(0.48, 0.45).dx, p(0.48, 0.45).dy)
      ..quadraticBezierTo(
          p(0.64, 0.47).dx, p(0.64, 0.47).dy, p(0.67, 0.62).dx, p(0.67, 0.62).dy)
      ..quadraticBezierTo(
          p(0.69, 0.74).dx, p(0.69, 0.74).dy, p(0.68, 0.86).dx, p(0.68, 0.86).dy);
    canvas.drawPath(airwayPath, airway);

    // --- Palais (toit de la bouche). ---
    final tissue = Paint()
      ..color = const Color(0xFFF5C9B8)
      ..style = PaintingStyle.fill;
    final palate = Path()
      ..moveTo(p(0.10, 0.36).dx, p(0.10, 0.36).dy)
      ..lineTo(p(0.50, 0.36).dx, p(0.50, 0.36).dy)
      ..quadraticBezierTo(
          p(0.58, 0.37).dx, p(0.58, 0.37).dy, p(0.60, 0.44).dx, p(0.60, 0.44).dy)
      ..lineTo(p(0.50, 0.40).dx, p(0.50, 0.40).dy)
      ..lineTo(p(0.10, 0.40).dx, p(0.10, 0.40).dy)
      ..close();
    canvas.drawPath(palate, tissue);

    // --- Cavité nasale (petites volutes au-dessus du palais). ---
    final nasal = Paint()
      ..color = const Color(0xFFE9E2F5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.22, w * 0.20, h * 0.11),
        Radius.circular(w * 0.03),
      ),
      nasal,
    );

    // --- Langue. ---
    final tonguePaint = Paint()
      ..color = const Color(0xFFEE8C7A)
      ..style = PaintingStyle.fill;
    final tongue = Path()
      ..moveTo(p(0.16, 0.66).dx, p(0.16, 0.66).dy)
      ..quadraticBezierTo(
          p(0.30, 0.50).dx, p(0.30, 0.50).dy, p(0.46, 0.52).dx, p(0.46, 0.52).dy)
      ..quadraticBezierTo(
          p(0.56, 0.54).dx, p(0.56, 0.54).dy, p(0.58, 0.62).dx, p(0.58, 0.62).dy)
      ..quadraticBezierTo(
          p(0.50, 0.66).dx, p(0.50, 0.66).dy, p(0.40, 0.66).dx, p(0.40, 0.66).dy)
      ..close();
    canvas.drawPath(tongue, tonguePaint);

    // --- Lèvres (à gauche, à l'entrée). ---
    final lips = Paint()..color = const Color(0xFFE0607A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.40, w * 0.05, h * 0.04),
        Radius.circular(w * 0.02),
      ),
      lips,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.47, w * 0.05, h * 0.04),
        Radius.circular(w * 0.02),
      ),
      lips,
    );

    // --- Étiquettes discrètes. ---
    _label(canvas, 'nez', p(0.14, 0.18), w);
    _label(canvas, 'palais', p(0.22, 0.335), w);
    _label(canvas, 'langue', p(0.30, 0.62), w);
    _label(canvas, 'lèvres', p(0.02, 0.55), w);
    _label(canvas, 'gorge', p(0.74, 0.66), w);
  }

  void _label(Canvas canvas, String text, Offset at, double w) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black45,
          fontSize: w * 0.038,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _VocalTractPainter oldDelegate) => false;
}
