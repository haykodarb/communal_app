import 'package:communal/presentation/book/book_create/book_create_page.dart';
import 'package:communal/presentation/book/book_edit/book_edit_page.dart';
import 'package:communal/presentation/book/book_foreign/book_foreign_page.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/community/community_create/community_create_page.dart';
import 'package:communal/presentation/community/community_invite/community_invite_page.dart';
import 'package:communal/presentation/community/community_list_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_create/community_discussions_topic_create_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_messages/community_discussions_topic_messages_page.dart';
import 'package:communal/presentation/community/community_specific/community_settings/community_settings_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_page.dart';
import 'package:communal/presentation/loans/loan_info/loan_info_page.dart';
import 'package:communal/presentation/loans/loans_page.dart';
import 'package:communal/presentation/login/login_page.dart';
import 'package:communal/presentation/book/book_owned/book_owned_page.dart';
import 'package:communal/presentation/book/book_list_page.dart';
import 'package:communal/presentation/login/login_password_recovery/login_password_recovery_page.dart';
import 'package:communal/presentation/messages/messages_page.dart';
import 'package:communal/presentation/messages/messages_specific/messages_specific_page.dart';
import 'package:communal/presentation/notifications/notifications_page.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_page.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_edit/profile_own_edit_page.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_page.dart';
import 'package:communal/presentation/register/register_page.dart';
import 'package:communal/presentation/register/register_resend/register_resend_page.dart';
import 'package:communal/presentation/search/search_community_details_page.dart';
import 'package:communal/presentation/search/search_page.dart';
import 'package:communal/presentation/start/password_reset/password_reset_page.dart';
import 'package:communal/presentation/start/start_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RouteNames {
  static const String appRoot = 'https://app.communal.ar/#';

  static const String startPage = '/auth';

  static const String passwordResetPage = '/reset';

  static const String loginPage = '/login';
  static const String loginRecoveryPage = '/recovery';

  static const String registerPage = '/register';
  static const String registerResendPage = '/resend';

  static const String profileOwnPage = '/my-profile';
  static const String profileOwnEditPage = '/edit';

  static const String profileOtherPage = '/profile/:userId';

  static const String searchPage = '/search';
  static const String searchCommunityDetailsPage = '/community/:communityId';

  static const String myBooks = '/my-books';
  static const String bookCreatePage = '/create';
  static const String bookOwnedPage = '/:bookId';
  static const String bookEditPage = '/edit';

  static const String foreignBooksPage = '/book/:bookId';

  static const String communityListPage = '/communities';
  static const String communityCreatePage = '/create';
  static const String communitySpecificPage = '/:communityId';
  static const String communitySettingsPage = '/settings';
  static const String communityInvitePage = '/members/invite';
  static const String communityDiscussionsTopicCreate = '/discussions/create';
  static const String communityDiscussionsTopic = '/discussions/:topicId';

  static const String invitationsPage = '/invitations';

  static const String loansPage = '/loans';
  static const String loanInfoPage = '/:loanId';

  static const String messagesPage = '/messages';
  static const String messagesSpecificPage = '/:userId';

  static const String notificationsPage = '/notifications';
}

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRoute _myBooksRoutes = GoRoute(
  path: RouteNames.myBooks,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) {
    return const NoTransitionPage(
      child: BookListPage(),
    );
  },
  routes: [
    GoRoute(
      path: RouteNames.bookCreatePage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: BookCreatePage(),
      ),
    ),
    GoRoute(
      path: RouteNames.bookOwnedPage,
      parentNavigatorKey: _shellNavigatorKey,
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
          parentNavigatorKey: _shellNavigatorKey,
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
final GoRoute _communityRoutes = GoRoute(
  path: RouteNames.communityListPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: CommunityListPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.communityCreatePage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CommunityCreatePage(),
      ),
    ),
    GoRoute(
      path: RouteNames.communitySpecificPage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: CommunitySpecificPage(
            communityId: state.pathParameters['communityId']!,
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.communityDiscussionsTopicCreate,
          parentNavigatorKey: _shellNavigatorKey,
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
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: CommunityDiscussionsTopicMessagesPage(
                topicId: state.pathParameters['topicId']!,
              ),
            );
          },
        ),
        GoRoute(
          path: RouteNames.communitySettingsPage,
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CommunitySettingsPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.communityInvitePage,
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state) => NoTransitionPage(
            child: CommunityInvitePage(
              communityId: state.pathParameters['communityId']!,
            ),
          ),
        ),
      ],
    ),
  ],
);

final GoRoute _messagesRoutes = GoRoute(
  path: RouteNames.messagesPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: MessagesPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.messagesSpecificPage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: MessagesSpecificPage(
            userId: state.pathParameters['userId']!,
          ),
        );
      },
    ),
  ],
);

final GoRoute _profilesRoutes = GoRoute(
  path: RouteNames.profileOtherPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: ProfileOtherPage(
        userId: state.pathParameters['userId']!,
      ),
    );
  },
);

final GoRoute _notificationsRoutes = GoRoute(
  path: RouteNames.notificationsPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: NotificationsPage(),
  ),
);

final GoRoute _foreignBookPage = GoRoute(
  path: RouteNames.foreignBooksPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: BookForeignPage(
        bookId: state.pathParameters['bookId']!,
      ),
    );
  },
);

final GoRoute _searchPage = GoRoute(
  path: RouteNames.searchPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) {
    return const NoTransitionPage(
      child: SearchPage(),
    );
  },
  routes: [
    GoRoute(
      path: RouteNames.searchCommunityDetailsPage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) => NoTransitionPage(
        child: SearchCommunityDetailsPage(
          communityId: state.pathParameters['communityId']!,
        ),
      ),
    ),
  ],
);

final GoRoute _loansRoutes = GoRoute(
  path: RouteNames.loansPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: LoansPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.loanInfoPage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoanInfoPage(
            loanId: state.pathParameters['loanId']!,
          ),
        );
      },
    )
  ],
);

final GoRoute _myProfileRoutes = GoRoute(
  path: RouteNames.profileOwnPage,
  parentNavigatorKey: _shellNavigatorKey,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: ProfileOwnPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.profileOwnEditPage,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProfileOwnEditPage(),
      ),
    ),
  ],
);

final GoRoute _startRoutes = GoRoute(
  path: RouteNames.startPage,
  redirect: (context, state) {
    if (Supabase.instance.client.auth.currentUser != null) {
      return RouteNames.communityListPage;
    }

    return null;
  },
  pageBuilder: (context, state) => const NoTransitionPage(
    child: StartPage(),
  ),
  routes: [
    GoRoute(
      path: RouteNames.passwordResetPage,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: PasswordResetPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.loginPage,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(),
      ),
      routes: [
        GoRoute(
          path: RouteNames.loginRecoveryPage,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoginPasswordRecoveryPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.registerPage,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: RegisterPage(),
      ),
      routes: [
        GoRoute(
          path: RouteNames.registerResendPage,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RegisterResendPage(),
          ),
        ),
      ],
    ),
  ],
);

final List<RouteBase> routes = <RouteBase>[
  _startRoutes,
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    redirect: (context, state) {
      if (Supabase.instance.client.auth.currentUser == null) {
        return RouteNames.startPage;
      }

      return null;
    },
    pageBuilder: (context, state, child) {
      if (!Get.isRegistered<CommonDrawerController>()) {
        Get.put(
          CommonDrawerController(initialRoute: state.matchedLocation),
        );
      }

      return NoTransitionPage(
        child: CommonResponsivePage(child: child),
      );
    },
    routes: [
      _loansRoutes,
      _searchPage,
      _communityRoutes,
      _myProfileRoutes,
      _profilesRoutes,
      _myBooksRoutes,
      _messagesRoutes,
      _notificationsRoutes,
      _foreignBookPage,
    ],
  ),
];
