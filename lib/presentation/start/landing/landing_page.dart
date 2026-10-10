import 'dart:math' as math;

import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LandingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt pageIndex = 0.obs;

  static const int pageCount = 3;

  void next(BuildContext context) {
    if (pageIndex.value == pageCount - 1) {
      context.go(RouteNames.startPage);
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

/// The three welcome pages shown on first launch, after the web's landing
/// page: your shelf, who's in your community, and how borrowing works. Each
/// has its own drawing, which plays once as the page comes in.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Widget _pageIndicator(BuildContext context, LandingController controller) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);

    return Obx(
      () {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            LandingController.pageCount,
            (int i) {
              final bool selected = controller.pageIndex.value == i;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: selected ? 45 : 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selected ? selectedColor : unselectedColor,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _page({
    required BuildContext context,
    required Widget graphic,
    required String title,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: graphic),
          ),
        ),
        // A fixed height, so a title that wraps (as some do in Spanish)
        // doesn't move that page's drawing out of line with the others.
        SizedBox(
          height: 176,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  height: 1.25,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 16),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LandingController(),
      builder: (LandingController controller) {
        final List<Widget> pages = [
          _page(
            context: context,
            graphic: const _ShelfGraphic(),
            title: 'Add your books'.tr,
            text: 'landing-shelf'.tr,
          ),
          _page(
            context: context,
            graphic: const _CommunityGraphic(),
            title: "Who's in your community".tr,
            text: 'landing-community'.tr,
          ),
          _page(
            context: context,
            graphic: const _BorrowingGraphic(),
            title: 'How borrowing works'.tr,
            text: 'landing-borrowing'.tr,
          ),
        ];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(
                          () {
                            final bool last = controller.pageIndex.value ==
                                LandingController.pageCount - 1;

                            // Kept in the layout on the last page so the
                            // pages don't jump.
                            return Visibility.maintain(
                              visible: !last,
                              child: TextButton(
                                onPressed: () =>
                                    context.go(RouteNames.startPage),
                                child: Text('Skip'.tr),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: controller.pageController,
                          onPageChanged: (int i) =>
                              controller.pageIndex.value = i,
                          children: pages,
                        ),
                      ),
                      const Divider(height: 20),
                      _pageIndicator(context, controller),
                      const Divider(height: 24),
                      CommonButton(
                        type: CommonButtonType.filled,
                        onPressed: controller.next,
                        child: Obx(
                          () {
                            final bool last = controller.pageIndex.value ==
                                LandingController.pageCount - 1;

                            return Text(last ? 'Get started'.tr : 'Next'.tr);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Plays a drawing's animation once, from 0 to 1, when it is first built
/// (the PageView builds a page as it starts sliding in). With reduced motion
/// it starts at the end.
class _PlayOnce extends StatelessWidget {
  const _PlayOnce({required this.duration, required this.builder});

  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduceMotion ? 1 : 0, end: 1),
      duration: duration,
      builder: (context, t, _) => builder(context, t),
    );
  }
}

/// How far [t] is through the part of the animation from [begin] to [end],
/// both fractions of the whole, eased by [curve].
double _interval(double t, double begin, double end,
    [Curve curve = Curves.easeOutCubic]) {
  return curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
}

// ---- Page 1: a shelf of books -----------------------------------------------

class _ShelfGraphic extends StatelessWidget {
  const _ShelfGraphic();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1 / _ShelfPainter.height,
      child: _PlayOnce(
        duration: const Duration(milliseconds: 1400),
        builder: (context, t) => CustomPaint(
          painter: _ShelfPainter(t: t, colors: colors),
        ),
      ),
    );
  }
}

class _ShelfPainter extends CustomPainter {
  _ShelfPainter({required this.t, required this.colors});

  final double t;
  final ColorScheme colors;

  /// The drawing's height, as a fraction of its width.
  static const double height = 0.62;

  // Each standing book's width and height (fractions of the drawing's side)
  // and colour; two more lie stacked at the end of the shelf.
  static const List<(double, double, int)> _books = [
    (0.085, 0.42, 0),
    (0.11, 0.50, 1),
    (0.07, 0.36, 2),
    (0.095, 0.46, 0),
    (0.12, 0.40, 2),
    (0.08, 0.52, 1),
  ];
  static const List<(double, double, int)> _stack = [
    (0.17, 0.06, 1),
    (0.14, 0.055, 0),
  ];

  Color _color(int i) => [colors.primary, colors.secondary, colors.tertiary][i];

  void _book(Canvas canvas, Rect rect, Color color, double opacity,
      {bool lying = false}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide * 0.12)),
      Paint()..color = color.withValues(alpha: opacity),
    );

    // Two bands across the spine, like the lettering on a real one.
    final Paint band = Paint()
      ..color = colors.surface.withValues(alpha: 0.55 * opacity);
    if (lying) {
      final double w = rect.width * 0.06;
      canvas.drawRect(
        Rect.fromLTWH(rect.left + rect.width * 0.12, rect.top, w, rect.height),
        band,
      );
      canvas.drawRect(
        Rect.fromLTWH(rect.right - rect.width * 0.18, rect.top, w, rect.height),
        band,
      );
    } else {
      final double h = rect.height * 0.05;
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top + rect.height * 0.12, rect.width, h),
        band,
      );
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.bottom - rect.height * 0.2, rect.width, h),
        band,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double shelfY = s * 0.56;
    const double gap = 0.012;

    // The plank.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.06, shelfY, s * 0.88, s * 0.035),
        Radius.circular(s * 0.0175),
      ),
      Paint()..color = colors.onSurface,
    );

    // Books drop onto it one after another.
    double progress(int i) =>
        _interval(t, i * 0.08, i * 0.08 + 0.4, Curves.easeOutBack);

    double x = s * 0.1;
    for (int i = 0; i < _books.length; i++) {
      final (double w, double h, int c) = _books[i];
      final double p = progress(i);
      final double drop = (1 - p) * s * 0.12;

      _book(
        canvas,
        Rect.fromLTWH(x, shelfY - h * s - drop, w * s, h * s),
        _color(c),
        p.clamp(0.0, 1.0),
      );
      x += (w + gap) * s;
    }

    double y = shelfY;
    for (int i = 0; i < _stack.length; i++) {
      final (double w, double h, int c) = _stack[i];
      final double p = progress(_books.length + i);
      final double drop = (1 - p) * s * 0.12;
      y -= h * s;

      _book(
        canvas,
        Rect.fromLTWH(x + s * 0.01 + i * s * 0.015, y - drop, w * s, h * s),
        _color(c),
        p.clamp(0.0, 1.0),
        lying: true,
      );
      y -= s * 0.004;
    }
  }

  @override
  bool shouldRepaint(_ShelfPainter old) => old.t != t || old.colors != colors;
}

// ---- Page 2: you, your friends and their friends ----------------------------

/// The web landing page's diagram: you in the middle, five friends on the
/// first ring, their friends on the second, and the boundary beyond it.
class _CommunityGraphic extends StatelessWidget {
  const _CommunityGraphic();

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: _PlayOnce(
              duration: const Duration(milliseconds: 1900),
              builder: (context, t) => CustomPaint(
                painter: _CommunityPainter(t: t, colors: colors),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 6,
          children: [
            _legendItem(context, colors.primary, 'You'.tr),
            _legendItem(context, colors.secondary, 'Friends'.tr),
            _legendItem(context, colors.tertiary, 'Friends of friends'.tr),
          ],
        ),
      ],
    );
  }
}

class _CommunityPainter extends CustomPainter {
  _CommunityPainter({required this.t, required this.colors});

  final double t;
  final ColorScheme colors;

  // Geometry on a 400 x 400 grid, scaled to the canvas.
  static const double _c = 200;
  static const double _r1 = 92;
  static const double _r2 = 158;
  static const List<double> _friendAngles = [-90, -18, 54, 126, 198];

  static Offset _polar(double r, double deg) => Offset(
        _c + r * math.cos(deg * math.pi / 180),
        _c + r * math.sin(deg * math.pi / 180),
      );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.shortestSide / 400);

    const Offset center = Offset(_c, _c);
    final List<Offset> friends =
        _friendAngles.map((double deg) => _polar(_r1, deg)).toList();
    // Each friend's own friends, fanned out around them on the outer ring.
    final List<(Offset, Offset)> outer = [
      for (int i = 0; i < friends.length; i++)
        for (final double d in i.isEven ? [-20.0, 20.0] : [-24.0, 0.0, 24.0])
          (friends[i], _polar(_r2, _friendAngles[i] + d)),
    ];

    final double lines = _interval(t, 0.1, 0.42);
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.onSurfaceVariant.withValues(alpha: 0.4 * lines);
    canvas.drawCircle(center, _r2, ring);
    canvas.drawCircle(center, _r1, ring);

    final Paint edge = Paint()
      ..strokeWidth = 1.5
      ..color = colors.onSurfaceVariant.withValues(alpha: 0.35 * lines);
    for (final (Offset from, Offset to) in outer) {
      canvas.drawLine(from, to, edge);
    }
    for (final Offset f in friends) {
      canvas.drawLine(center, f, edge);
    }

    // The boundary: a dashed circle, last to appear.
    final Paint dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = colors.onSurfaceVariant
          .withValues(alpha: 0.6 * _interval(t, 0.68, 1));
    const int dashes = 110;
    for (int i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 190),
        i * 2 * math.pi / dashes,
        2 * math.pi / dashes * 0.4,
        false,
        dash,
      );
    }

    // Nodes grow outwards from you, each ringed in the background colour.
    void node(Offset at, double radius, Color color, double p) {
      if (p <= 0) return;
      canvas.drawCircle(at, (radius + 4) * p, Paint()..color = colors.surface);
      canvas.drawCircle(at, radius * p, Paint()..color = color);
    }

    for (int i = 0; i < outer.length; i++) {
      final double begin = 0.37 + i * 0.02;
      node(outer[i].$2, 11, colors.tertiary,
          _interval(t, begin, begin + 0.26, Curves.easeOutBack));
    }
    for (int i = 0; i < friends.length; i++) {
      final double begin = 0.13 + i * 0.037;
      node(friends[i], 17, colors.secondary,
          _interval(t, begin, begin + 0.26, Curves.easeOutBack));
    }
    node(center, 26, colors.primary, _interval(t, 0, 0.26, Curves.easeOutBack));
  }

  @override
  bool shouldRepaint(_CommunityPainter old) =>
      old.t != t || old.colors != colors;
}

// ---- Page 3: request, accept, return ----------------------------------------

/// The loan page's timeline, as on the web: a line through three steps, drawn
/// left to right with a book riding along its end.
class _BorrowingGraphic extends StatelessWidget {
  const _BorrowingGraphic();

  static const List<(String, String)> _steps = [
    ('Request', 'Ask the owner'),
    ('Accept', 'Meet up'),
    ('Return', "When you're done"),
  ];

  static const double _markerSize = 32;
  static const double _bookWidth = 44;
  static const double _bookHeight = 60;

  Widget _marker(ColorScheme colors, double p) {
    return Transform.scale(
      scale: p,
      child: Container(
        width: _markerSize,
        height: _markerSize,
        padding: const EdgeInsets.all(10),
        decoration:
            BoxDecoration(color: colors.onSurface, shape: BoxShape.circle),
        child: Container(
          decoration:
              BoxDecoration(color: colors.surface, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _book(ColorScheme colors) {
    return CustomPaint(
      size: const Size(_bookWidth, _bookHeight),
      painter: _BookPainter(colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return _PlayOnce(
      duration: const Duration(milliseconds: 1800),
      builder: (context, t) {
        // The line takes most of the time; each step pops in as it arrives.
        final double track = _interval(t, 0.05, 0.75, Curves.easeInOutCubic);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Each step's marker sits in the middle of a third of the width.
            final double column = constraints.maxWidth / 3;
            final double start = column / 2;
            final double length = column * 2;
            const double trackTop = _bookHeight + 28;

            return SizedBox(
              height: trackTop + 120,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: start,
                    top: trackTop + _markerSize / 2 - 2.5,
                    width: length * track,
                    height: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.onSurface,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  // The book hops from step to step, landing on each one.
                  Positioned(
                    left: start + length * track - _bookWidth / 2,
                    top: 8 - 8 * math.sin(track * 2 * math.pi).abs(),
                    child: _book(colors),
                  ),
                  for (int i = 0; i < _steps.length; i++)
                    Positioned(
                      // Inset a little so neighbouring captions don't touch;
                      // the marker stays centred over its third.
                      left: column * i + 3,
                      width: column - 6,
                      top: trackTop,
                      child: Column(
                        children: [
                          _marker(
                            colors,
                            _interval(t, 0.05 + i * 0.33, 0.25 + i * 0.33,
                                Curves.easeOutBack),
                          ),
                          const SizedBox(height: 14),
                          Opacity(
                            opacity:
                                _interval(t, 0.1 + i * 0.33, 0.3 + i * 0.33),
                            child: Column(
                              children: [
                                Text(
                                  _steps[i].$1.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _steps[i].$2.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// A closed book, front on: the cover with a darker spine down its left edge
/// and the pages showing along the bottom, and a title label on the cover.
class _BookPainter extends CustomPainter {
  _BookPainter({required this.colors});

  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    const double spine = 8;
    const double pages = 7;
    const Radius radius = Radius.circular(4);

    // The pages: a paper-coloured block under the cover's bottom edge, with
    // a couple of lines for the leaves.
    const Color paper = Color(0xFFfffaf3);
    final Rect pagesRect = Rect.fromLTRB(spine - 2, h - pages - 4, w - 2, h);
    canvas.drawRRect(
      RRect.fromRectAndCorners(pagesRect,
          bottomRight: radius, bottomLeft: const Radius.circular(2)),
      Paint()..color = paper,
    );
    final Paint leaf = Paint()
      ..color = const Color(0xFF797593).withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (final double y in [h - 4.5, h - 2]) {
      canvas.drawLine(Offset(spine + 1, y), Offset(w - 5, y), leaf);
    }

    // The cover, and the spine down its left edge.
    final Rect cover = Rect.fromLTRB(0, 0, w, h - pages);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cover, radius),
      Paint()..color = colors.primary,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(0, 0, spine, h),
        topLeft: radius,
        bottomLeft: radius,
      ),
      Paint()
        ..color = Color.alphaBlend(
            Colors.black.withValues(alpha: 0.18), colors.primary),
    );

    // A title label and an author line on the cover.
    final Paint label = Paint()..color = paper.withValues(alpha: 0.85);
    const double left = spine + 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, h * 0.18, w - 6, h * 0.18 + 10),
        const Radius.circular(2),
      ),
      label,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left + 4, h * 0.18 + 15, w - 10, h * 0.18 + 18),
        const Radius.circular(1.5),
      ),
      label,
    );
  }

  @override
  bool shouldRepaint(_BookPainter old) => old.colors != colors;
}
