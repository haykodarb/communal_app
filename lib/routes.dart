import 'package:communal/models/profile.dart';
import 'package:communal/presentation/book/book_create/book_create_page.dart';
import 'package:communal/presentation/book/book_edit/book_edit_page.dart';
import 'package:communal/presentation/community/community_create/community_create_page.dart';
import 'package:communal/presentation/community/community_list_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_create/community_discussions_topic_create_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_messages/community_discussions_topic_messages_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_page.dart';
import 'package:communal/presentation/loans/loan_info/loan_info_page.dart';
import 'package:communal/presentation/loans/loans_page.dart';
import 'package:communal/presentation/login/login_page.dart';
import 'package:communal/presentation/book/book_owned/book_owned_page.dart';
import 'package:communal/presentation/book/book_list_page.dart';
import 'package:communal/presentation/messages/messages_page.dart';
import 'package:communal/presentation/messages/messages_specific/messages_specific_page.dart';
import 'package:communal/presentation/notifications/notifications_page.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_page.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_page.dart';
import 'package:communal/presentation/register/register_page.dart';
import 'package:communal/presentation/start/start_page.dart';
import 'package:go_router/go_router.dart';

class RouteNames {
  static const String startPage = '/';

  static const String loginPage = '/login';
  static const String loginRecoveryPage = '/login/recovery';

  static const String registerPage = '/register';
  static const String registerResendPage = '/register/resend';

  static const String profileOwnPage = '/my-profile';
  static const String profileOwnEditPage = '/edit';

  static const String profileOtherPage = '/profile/:userId';
  static const String profileOtherBookPage = '/book/:bookId';

  static const String myBooks = '/my-books';
  static const String bookCreatePage = '/create';
  static const String bookOwnedPage = '/:bookId';
  static const String bookEditPage = '/edit';

  static const String communityListPage = '/communities';
  static const String communityCreatePage = '/create';
  static const String communitySpecificPage = '/:communityId';
  static const String communitySettingsPage = '/settings';
  static const String communitySpecificBookPage = '/book/:bookId';
  static const String communityInvitePage = '/invite';
  static const String communityDiscussionsTopicCreate = '/discussions/create';
  static const String communityDiscussionsTopic = '/discussions/:topicId';

  static const String invitationsPage = '/invitations';

  static const String loansPage = '/loans';
  static const String loanInfoPage = '/:loanId';

  static const String messagesPage = '/messages';
  static const String messagesSpecificPage = '/:userId';

  static const String notificationsPage = '/notifications';
}

final GoRoute _myBooksRoutes = GoRoute(
  path: RouteNames.myBooks,
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: BookListPage(),
    );
  },
  routes: [
    GoRoute(
      path: RouteNames.bookCreatePage,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: BookCreatePage(),
      ),
    ),
    GoRoute(
      path: RouteNames.bookOwnedPage,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: BookOwnedPage(
            bookId: state.pathParameters['bookId']!,
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.bookEditPage,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: BookEditPage(
                bookId: state.pathParameters['bookId']!,
              ),
            );
          },
        ),
      ],
    ),
  ],
);

final GoRoute _startRoutes = GoRoute(
  path: RouteNames.startPage,
  builder: (context, state) => const StartPage(),
  routes: [
    GoRoute(
      path: RouteNames.loginPage,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.registerPage,
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);

final GoRoute _communityRoutes = GoRoute(
  path: RouteNames.communityListPage,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: CommunityListPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.communityCreatePage,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CommunityCreatePage(),
      ),
    ),
    GoRoute(
      path: RouteNames.communitySpecificPage,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: CommunitySpecificPage(
            communityId: state.pathParameters['communityId']!,
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.communitySpecificBookPage,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: CommunitySpecificBookPage(
                bookId: state.pathParameters['bookId']!,
              ),
            );
          },
        ),
        GoRoute(
          path: RouteNames.communityDiscussionsTopicCreate,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: CommunityDiscussionsTopicCreatePage(
                communityId: state.pathParameters['communityId']!,
              ),
            );
          },
        ),
        GoRoute(
          path: RouteNames.communityDiscussionsTopic,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: CommunityDiscussionsTopicMessagesPage(
                topicId: state.pathParameters['topicId']!,
              ),
            );
          },
        ),
      ],
    ),
  ],
);

final GoRoute _messagesRoutes = GoRoute(
  path: RouteNames.messagesPage,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: MessagesPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.messagesSpecificPage,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: MessagesSpecificPage(
            userId: state.pathParameters['userId']!,
            userProfile: state.extra as Profile?,
          ),
        );
      },
    ),
  ],
);

final GoRoute _profilesRoutes = GoRoute(
  path: RouteNames.profileOtherPage,
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: ProfileOtherPage(
        userId: state.pathParameters['userId']!,
      ),
    );
  },
  routes: [
    GoRoute(
      path: RouteNames.profileOtherBookPage,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: CommunitySpecificBookPage(
            bookId: state.pathParameters['bookId']!,
          ),
        );
      },
    ),
  ],
);

final GoRoute _notificationsRoutes = GoRoute(
  path: RouteNames.notificationsPage,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: NotificationsPage(),
  ),
);

final GoRoute _loansRoutes = GoRoute(
    path: RouteNames.loansPage,
    pageBuilder: (context, state) => const NoTransitionPage(
          child: LoansPage(),
        ),
    routes: [
      GoRoute(
        path: RouteNames.loanInfoPage,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: LoanInfoPage(
              loanId: state.pathParameters['loanId']!,
            ),
          );
        },
      )
    ]);

final List<GoRoute> routes = <GoRoute>[
  GoRoute(
    path: RouteNames.profileOwnPage,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: ProfileOwnPage(),
    ),
  ),
  _loansRoutes,
  _communityRoutes,
  _profilesRoutes,
  _myBooksRoutes,
  _startRoutes,
  _messagesRoutes,
  _notificationsRoutes,
];
