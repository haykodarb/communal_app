import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loan_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// A review in a list, laid out like CommonLoanCard: the book and the review
/// text on the left, the cover on the right, the date in the top corner. Long
/// reviews clamp to 4 lines (the loan page has the rest). `showReviewer` adds
/// who wrote it as a byline under the text, for lists mixing several people
/// (Home, Reviews by friends).
class CommonReviewCard extends StatelessWidget {
  const CommonReviewCard({
    super.key,
    required this.loan,
    this.showReviewer = false,
  });

  final Loan loan;
  final bool showReviewer;

  @override
  Widget build(BuildContext context) {
    final Color variant = Theme.of(context).colorScheme.onSurfaceVariant;

    return CommonLoanCardBox(
      loan: loan,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      loan.book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        color: variant,
                      ),
                    ),
                  ],
                ),
              ),
              if (loan.latest_date != null) ...[
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, y', Get.locale?.languageCode)
                      .format(loan.latest_date!),
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.2,
                    color: variant,
                  ),
                ),
              ],
            ],
          ),
          // Pinned to the bottom, so spare space goes between the book and
          // the text.
          const Spacer(),
          const SizedBox(height: 8),
          Text(
            loan.review ?? '',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          if (showReviewer) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                // A fixed box: the card's IntrinsicHeight can't measure the
                // default avatar's LayoutBuilder.
                SizedBox.square(
                  dimension: 20,
                  child: CommonCircularAvatar(profile: loan.loanee, radius: 10),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    loan.loanee.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
