import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/routes.dart';
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

/// One cell of the info pill under the title (Owner, Added, Status...).
class BookInfoItem {
  const BookInfoItem(this.label, this.value);

  final String label;
  final Widget value;
}

/// Shared layout of BookOwnedPage / BookForeignPage. The page scrolls as a
/// whole: the cover and title stay on top and shrink as you scroll, the info
/// pill and the reviews pass under them, and the action buttons stay pinned
/// at the bottom.
class BookDetailView extends StatefulWidget {
  const BookDetailView({
    super.key,
    required this.book,
    required this.info,
    required this.actions,
    this.expandCoverOnTap = false,
  });

  final Book book;
  final List<BookInfoItem> info;
  final Widget actions;
  final bool expandCoverOnTap;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  final ScrollController _scroll = ScrollController();
  late final BookReviewsList _reviews = BookReviewsList(bookId: widget.book.id);
  late final Worker _afterLoad;

  @override
  void initState() {
    super.initState();

    _scroll.addListener(_maybeLoadMore);

    // A page that doesn't fill the screen can't be scrolled to load the next
    // one, so keep loading until it does (or there are no more).
    _afterLoad = ever(_reviews.loading, (bool loading) {
      if (loading) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
    });

    _reviews.loadMore();
  }

  @override
  void dispose() {
    _afterLoad.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!mounted || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 200) _reviews.loadMore();
  }

  /// The cover, title and author. As [progress] goes from 0 (top of the page)
  /// to 1 (one full screen scrolled) the cover shrinks to 60% and the text to
  /// 70%. Behind the cover's top half is the page background; a rounded card
  /// starts at its midpoint and hides the content sliding under it.
  Widget _header(
    BuildContext context,
    double height, {
    double progress = 0,
    double shadow = 0,
    bool placeholder = false,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double gap = height * 0.05;
    final double cover = height * 0.46 * (1 - 0.4 * progress);
    final double textScale = 1 - 0.3 * progress;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        // Elevation cue (hairline + soft shadow) that fades in quickly as you
        // scroll, so the list clearly passes under the header.
        boxShadow: shadow == 0
            ? null
            : [
                BoxShadow(
                  offset: const Offset(0, 2),
                  color: colors.onSurface.withValues(alpha: 0.08 * shadow),
                ),
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 10,
                  color: colors.shadow.withValues(alpha: 0.5 * shadow),
                ),
              ],
      ),
      child: Stack(
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
                  child: placeholder
                      ? null
                      : Center(
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
                            child: CommonBookCover(
                              widget.book,
                              expandOnTap: widget.expandCoverOnTap,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 20 - 10 * progress),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        widget.book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24 * textScale,
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
                          fontSize: 20 * textScale,
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
  }

  Widget _infoPill(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          for (final BookInfoItem item in widget.info)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: item.value,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _reviewItems(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? ownerReview = widget.book.review;

    // The owner's own review has no date and is shown first.
    final List<Widget> reviews = [
      if (ownerReview != null && ownerReview.isNotEmpty)
        BookReviewItem(author: widget.book.owner, text: ownerReview),
      for (final Loan loan in _reviews.items)
        BookReviewItem(
          author: loan.loanee,
          text: loan.review ?? '',
          date: loan.latest_date,
        ),
    ];

    if (reviews.isEmpty &&
        !_reviews.loading.value &&
        _reviews.fullyLoaded.value &&
        _reviews.error.value == null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Text(
            'No reviews'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: colors.onSurfaceVariant),
          ),
        ),
      ];
    }

    return [
      for (int i = 0; i < reviews.length; i++)
        if (i == 0)
          // A little air between the info pill and the first review.
          Padding(padding: const EdgeInsets.only(top: 6), child: reviews[i])
        else
          // A very subtle divider between reviews.
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10),
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      // The content's card color; the header paints the page background above
      // the cover's midpoint.
      backgroundColor: colors.surfaceContainer,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double height = constraints.maxHeight;

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scroll,
                        slivers: [
                          // Room for the header at full size, which the
                          // content then scrolls under.
                          SliverToBoxAdapter(
                            child: ExcludeSemantics(
                              child: Opacity(
                                opacity: 0,
                                child: _header(
                                  context,
                                  height,
                                  placeholder: true,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            sliver: SliverToBoxAdapter(
                              child: _infoPill(context),
                            ),
                          ),
                          // The bottom padding separates the list from the
                          // pinned buttons.
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                        child: AnimatedBuilder(
                          animation: _scroll,
                          builder: (context, _) {
                            final double y =
                                _scroll.hasClients ? _scroll.offset : 0;

                            return _header(
                              context,
                              height,
                              // The header shrinks over one full screen of
                              // scrolling; its shadow ramps up much sooner.
                              progress: (y / height).clamp(0.0, 1.0),
                              shadow: (y / 60).clamp(0.0, 1.0),
                            );
                          },
                        ),
                      ),
                      if (Navigator.of(context).canPop())
                        const Positioned(
                          top: 4,
                          left: 4,
                          child: BackButton(),
                        ),
                    ],
                  ),
                ),
                // Pinned at the bottom; the space above it lives in the list
                // so the buttons hug the edges.
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: widget.actions,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One review in the book page's list: author, optional date and the text,
/// clamped to 4 lines and expanded on tap.
class BookReviewItem extends StatefulWidget {
  const BookReviewItem({
    super.key,
    required this.author,
    required this.text,
    this.date,
  });

  final Profile author;
  final String text;
  final DateTime? date;

  @override
  State<BookReviewItem> createState() => _BookReviewItemState();
}

class _BookReviewItemState extends State<BookReviewItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: widget.author.isCurrentUser
                    ? null
                    : () => context.push(
                          RouteNames.profileOtherPage
                              .replaceFirst(':userId', widget.author.id),
                        ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonCircularAvatar(profile: widget.author, radius: 15),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.author.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.date != null) ...[
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            widget.text,
            maxLines: expanded ? null : 4,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}
