import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The card box shared by CommonLoanCard and CommonReviewCard: 20px padding,
/// a 10px radius and a 96x128 cover on the right whose radius is concentric
/// with the card's (its radius minus its padding), 5px at least.
class CommonLoanCardBox extends StatelessWidget {
  const CommonLoanCardBox({
    super.key,
    required this.loan,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  static const double padding = 20;
  static const double radius = 10;
  static const double coverWidth = 96;
  static const double coverHeight = 128;

  final Loan loan;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: WidgetStateColor.transparent,
      highlightColor: Colors.transparent,
      onTap: () => context.push('${RouteNames.loansPage}/${loan.id}'),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                Expanded(child: child),
                const VerticalDivider(width: 10),
                SizedBox(
                  width: coverWidth,
                  height: coverHeight,
                  child: CommonBookCover(
                    loan.book,
                    radius: radius - padding < 5 ? 5 : radius - padding,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A loan in a list (Loans, Home): the book, the other person and their role,
/// the loan's state and its latest date.
class CommonLoanCard extends StatelessWidget {
  const CommonLoanCard({super.key, required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final Color variant = Theme.of(context).colorScheme.onSurfaceVariant;
    final TextStyle detailStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.2,
      color: variant,
    );

    return CommonLoanCardBox(
      loan: loan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loan.book.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const Divider(height: 5),
          Text(
            loan.book.author,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: detailStyle,
          ),
          const Divider(height: 20),
          Row(
            children: [
              Flexible(
                child: Text(
                  loan.loanee.isCurrentUser
                      ? loan.book.owner.username
                      : loan.loanee.username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              const VerticalDivider(width: 5),
              Container(
                decoration: BoxDecoration(
                  color: (loan.loanee.isCurrentUser
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 10,
                ),
                child: Text(
                  loan.loanee.isCurrentUser ? 'Owner'.tr : 'Loanee'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 5),
          Text(
            loan.returned
                ? 'Loan completed'.tr
                : loan.accepted
                    ? 'On loan'.tr
                    : loan.rejected
                        ? 'Loan rejected'.tr
                        : 'Awaiting approval'.tr,
            style: detailStyle,
          ),
          const Divider(height: 5),
          Text(
            '${loan.returned ? 'Returned'.tr : loan.accepted ? 'Approved'.tr : loan.rejected ? 'Rejected'.tr : 'Requested'.tr}${DateFormat(' MMMM d, y', Get.locale?.languageCode).format(loan.latest_date ?? loan.created_at)}',
            style: detailStyle,
          ),
        ],
      ),
    );
  }
}
