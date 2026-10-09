import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_user_link.dart';
import 'package:communal/routes.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The book page's reviews (completed loans that left one), newest first,
/// loaded a page at a time as the page scrolls.
class BookReviewsList {
  BookReviewsList({required this.bookId});

  static const int pageSize = 5;

  final String bookId;

  final RxList<Loan> items = <Loan>[].obs;
  final RxBool loading = false.obs;
  final RxBool fullyLoaded = false.obs;
  final RxnString error = RxnString();

  /// How many readers reviewed the book, for the heading.
  final RxInt count = 0.obs;

  Future<void> loadCount() async {
    final BackendResponse<int> response =
        await LoansBackend.getReviewCountForBook(bookId);

    if (response.success) count.value = response.payload ?? 0;
  }

  Future<void> loadMore() async {
    if (loading.value || fullyLoaded.value) return;

    loading.value = true;

    final BackendResponse response =
        await LoansBackend.getCompletedLoansForItem(
      bookId: bookId,
      pageKey: items.length,
      pageSize: pageSize,
    );

    if (response.success) {
      final List<Loan> page = response.payload;
      items.addAll(page);
      if (page.length < pageSize) fullyLoaded.value = true;
    } else {
      // Stop here rather than retrying on every scroll.
      error.value = response.payload;
      fullyLoaded.value = true;
    }

    loading.value = false;
  }
}

/// One cell of the info row under the title (Status, Added, Owner...).
class BookInfoItem {
  const BookInfoItem(this.label, this.value);

  final String label;
  final Widget value;
}

/// Shared layout of BookOwnedPage / BookForeignPage. The page scrolls as a
/// whole: the cover, title and info row scroll away, and once the title is
/// out of view a compact bar (back, a thumbnail, title and author) takes over
/// at the top, so the reviews get most of the screen. Tapping the cover shows
/// it large. The action buttons stay pinned at the bottom.
class BookDetailView extends StatefulWidget {
  const BookDetailView({
    super.key,
    required this.book,
    required this.info,
    required this.actions,
  });

  final Book book;
  final List<BookInfoItem> info;
  final Widget actions;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  /// The compact bar's height; it shows once the title has gone under it.
  static const double _barHeight = 56;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();
  late final BookReviewsList _reviews = BookReviewsList(bookId: widget.book.id);
  late final Worker _afterLoad;

  bool _compact = false;

  @override
  void initState() {
    super.initState();

    _scroll.addListener(_onScroll);

    // A page that doesn't fill the screen can't be scrolled to load the next
    // one, so keep loading until it does (or there are no more).
    _afterLoad = ever(_reviews.loading, (bool loading) {
      if (loading) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
    });

    _reviews.loadCount();
    _reviews.loadMore();
  }

  @override
  void dispose() {
    _afterLoad.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    _maybeLoadMore();

    final RenderBox? title =
        _titleKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stack =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (title == null || stack == null || !title.attached) return;

    final double bottom =
        title.localToGlobal(Offset(0, title.size.height), ancestor: stack).dy;
    final bool compact = bottom < _barHeight;

    if (compact != _compact) setState(() => _compact = compact);
  }

  void _maybeLoadMore() {
    if (!mounted || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 200) _reviews.loadMore();
  }

  /// The cover shown large over a dimmed page; a tap anywhere closes it.
  void _openCover() {
    final Size size = MediaQuery.sizeOf(context);
    final double height =
        (size.height * 0.9).clamp(0, size.width * 0.9 * 4 / 3);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      animationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 160),
      ),
      // Dialog supplies the Material the cover's InkWell needs. A tap on the
      // cover closes it; a tap on the dimmed page does too (the barrier).
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: MouseRegion(
          cursor: SystemMouseCursors.zoomOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: SizedBox(
              height: height,
              child: IgnorePointer(
                child: CommonBookCover(widget.book, radius: 8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The cover, title and author. Behind the cover's top half is the page
  /// background; the near-white card starts at its midpoint.
  Widget _header(BuildContext context, double height) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double gap = height * 0.05;
    final double cover = height * 0.46;

    return Stack(
      children: [
        Positioned(
          top: gap + cover / 2,
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, gap, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: cover,
                child: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.zoomIn,
                    child: GestureDetector(
                      onTap: _openCover,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(2, 1),
                              blurRadius: 20,
                              spreadRadius: 12,
                              color: colors.surface,
                            ),
                          ],
                        ),
                        child: CommonBookCover(widget.book),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                key: _titleKey,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      widget.book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      widget.book.author,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(top: 4, left: 4, child: _BookBackButton()),
      ],
    );
  }

  /// Takes over the top of the page once the title has scrolled under it.
  Widget _compactBar(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return IgnorePointer(
      ignoring: !_compact,
      child: AnimatedOpacity(
        opacity: _compact ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _compact ? Offset.zero : const Offset(0, -8 / _barHeight),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Container(
            height: _barHeight,
            padding: const EdgeInsets.only(left: 4, right: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              // The same soft drop shadow as the chat's bar.
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 3),
                  blurRadius: 12,
                  color: colors.shadow.withValues(alpha: 0.75),
                ),
              ],
            ),
            child: Row(
              children: [
                const _BookBackButton(),
                const SizedBox(width: 6),
                SizedBox(
                  width: 30,
                  height: 40,
                  child: CommonBookCover(widget.book, radius: 4),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        widget.book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Centred cells with uppercase labels, separated by faint dividers.
  Widget _infoRow(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color divider = colors.onSurface.withValues(alpha: 0.12);

    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (int i = 0; i < widget.info.length; i++) ...[
              if (i > 0) Container(width: 1, height: 65 * 0.64, color: divider),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.info[i].label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: widget.info[i].value,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// "Reviews · N" and the list; nothing at all when there are no reviews.
  List<Widget> _reviewItems(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? ownerReview = widget.book.review;
    final bool hasOwnerReview = ownerReview != null && ownerReview.isNotEmpty;

    // The owner's own review has no date and is shown first.
    final List<Widget> reviews = [
      if (hasOwnerReview)
        BookReviewItem(
          author: widget.book.owner,
          text: ownerReview,
          tag: "Owner's note".tr,
        ),
      for (final Loan loan in _reviews.items)
        BookReviewItem(
          author: loan.loanee,
          text: loan.review ?? '',
          date: loan.latest_date,
        ),
    ];

    final bool empty = reviews.isEmpty &&
        !_reviews.loading.value &&
        _reviews.fullyLoaded.value &&
        _reviews.error.value == null;

    if (empty) return [];

    final int total = _reviews.count.value + (hasOwnerReview ? 1 : 0);

    return [
      // Separates the reviews from the book's facts above.
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text.rich(
          TextSpan(
            text: 'Reviews'.tr,
            children: [
              if (total > 0)
                TextSpan(
                  text: '  · $total',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      for (int i = 0; i < reviews.length; i++)
        if (i == 0)
          // A little air above the first review.
          Padding(padding: const EdgeInsets.only(top: 6), child: reviews[i])
        else
          // A very subtle divider between reviews.
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.onSurface.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: reviews[i],
          ),
      if (_reviews.error.value != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            _reviews.error.value!,
            style: TextStyle(fontSize: 13, color: colors.error),
          ),
        ),
      if (_reviews.loading.value)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: CommonLoadingBody(size: 20),
        ),
    ];
  }

  /// Height of the floating actions, measured after layout.
  double _actionsHeight = 0;

  /// Outlined buttons are see-through; give them the card colour.
  Widget _opaqueButtons(BuildContext context, Widget child) {
    final ThemeData theme = Theme.of(context);
    final ButtonStyle fill = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainer),
    );

    return Theme(
      data: theme.copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: theme.outlinedButtonTheme.style?.merge(fill) ?? fill,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      // The content's card colour; the header paints the page background
      // above the cover's midpoint.
      backgroundColor: colors.surfaceContainer,
      // No toolbar: only paints the status bar (and sets its icons), in the
      // header's colour, or the compact bar's once that takes over.
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: _compact ? colors.surfaceContainer : colors.surface,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double height = constraints.maxHeight;

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    key: _stackKey,
                    children: [
                      CustomScrollView(
                        controller: _scroll,
                        slivers: [
                          SliverToBoxAdapter(
                            child: ColoredBox(
                              color: colors.surface,
                              child: _header(context, height),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            sliver: SliverToBoxAdapter(
                              child: _infoRow(context),
                            ),
                          ),
                          // The bottom padding keeps the last review clear of
                          // the floating buttons.
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              20 + _actionsHeight,
                            ),
                            sliver: Obx(
                              () => SliverList.list(
                                children: _reviewItems(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _compactBar(context),
                      ),
                      // Floats over the reviews: nothing behind the buttons,
                      // which get solid fills so the reviews don't show
                      // through them.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _MeasureHeight(
                          onChange: (double value) {
                            if (mounted && value != _actionsHeight) {
                              setState(() => _actionsHeight = value);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                            child: _opaqueButtons(context, widget.actions),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Reports its child's height after each layout.
class _MeasureHeight extends SingleChildRenderObjectWidget {
  const _MeasureHeight({required this.onChange, required super.child});

  final void Function(double) onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureHeight(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureHeight renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  _RenderMeasureHeight(this.onChange);

  void Function(double) onChange;
  double? _last;

  @override
  void performLayout() {
    super.performLayout();
    final double height = size.height;
    if (height == _last) return;
    _last = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(height));
  }
}

/// One review in the book page's list: author, a date or a [tag] ("Owner's
/// note"), and the text clamped to 4 lines. Only a review that's actually cut
/// off can be expanded; the text is selectable.
class BookReviewItem extends StatefulWidget {
  const BookReviewItem({
    super.key,
    required this.author,
    required this.text,
    this.date,
    this.tag,
    this.showAuthor = true,
  });

  final Profile author;
  final String text;
  final DateTime? date;
  final String? tag;

  /// Off where the reviewer is already clear from the page (the loan card).
  final bool showAuthor;

  @override
  State<BookReviewItem> createState() => _BookReviewItemState();
}

class _BookReviewItemState extends State<BookReviewItem> {
  static const int _maxLines = 4;
  static const TextStyle _textStyle = TextStyle(fontSize: 14, height: 1.5);

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: widget.showAuthor
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (widget.showAuthor)
              Flexible(
                child: CommonUserLink(profile: widget.author, avatarSize: 30),
              ),
            if (widget.tag != null) ...[
              const SizedBox(width: 8),
              BookReviewTag(label: widget.tag!),
            ] else if (widget.date != null) ...[
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMd(Get.locale?.languageCode).format(widget.date!),
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final TextPainter painter = TextPainter(
              text: TextSpan(text: widget.text, style: _textStyle),
              maxLines: _maxLines,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: constraints.maxWidth);
            final bool expandable = painter.didExceedMaxLines || expanded;
            painter.dispose();

            final Widget text = Text(
              widget.text,
              maxLines: expanded ? null : _maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: _textStyle,
            );

            // The text stays selectable. The tap handler sits inside the
            // SelectionArea so it wins the tap over the selection's own
            // recognizer; dragging still selects.
            return SelectionArea(
              child: !expandable
                  ? text
                  : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => expanded = !expanded),
                        child: text,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}

/// A small uppercase label saying what a review is ("Owner's note", "Your
/// review").
class BookReviewTag extends StatelessWidget {
  const BookReviewTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.44,
          color: color,
        ),
      ),
    );
  }
}

/// Always shown: goes back when there's somewhere to go back to, and to Home
/// when the book page is the first page (a reload, a shared link).
class _BookBackButton extends StatelessWidget {
  const _BookBackButton();

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: () =>
          context.canPop() ? context.pop() : context.go(RouteNames.homePage),
    );
  }
}
