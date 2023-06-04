import 'package:communal/presentation/community/community_invite/community_invite_page.dart';
import 'package:communal/presentation/community/community_list_page.dart';
import 'package:communal/presentation/community/community_create/community_create_page.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_page.dart';
import 'package:communal/presentation/invitations/invitations_page.dart';
import 'package:communal/presentation/loans/loans_page.dart';
import 'package:communal/presentation/login/login_page.dart';
import 'package:communal/presentation/book/book_create/book_create_page.dart';
import 'package:communal/presentation/book/book_owned/book_owned_page.dart';
import 'package:communal/presentation/book/book_list_page.dart';
import 'package:communal/presentation/register/register_page.dart';
import 'package:communal/presentation/start/start_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class RouteNames {
  static const String startPage = '/start';
  static const String loginPage = '/login';
  static const String registerPage = '/register';
  static const String dashboardPage = '/dashboard';
  static const String bookListPage = '/book';
  static const String bookCreatePage = '/book/create';
  static const String bookOwnedPage = '/book/owned';
  static const String communityListPage = '/community';
  static const String communityCreatePage = '/community/create';
  static const String communitySpecificPage = '/community/specific';
  static const String communitySpecificBookPage = '/community/specific/book';
  static const String communityInvitePage = '/community/invite';
  static const String communityMembersPage = '/community/members';
  static const String invitationsPage = '/invitations';
  static const String loansPage = '/loans';
}

List<GetPage> routes() => <GetPage>[
      GetPage<dynamic>(
        name: RouteNames.startPage,
        transition: Transition.noTransition,
        page: () => const StartPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.loginPage,
        page: () => const LoginPage(),
        transition: Transition.downToUp,
        transitionDuration: const Duration(
          milliseconds: 300,
        ),
      ),
      GetPage<dynamic>(
        name: RouteNames.registerPage,
        page: () => const RegisterPage(),
        transition: Transition.downToUp,
        transitionDuration: const Duration(
          milliseconds: 300,
        ),
      ),
      GetPage<dynamic>(
        name: RouteNames.bookListPage,
        transition: Transition.noTransition,
        page: () => const BookListPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.bookCreatePage,
        transition: Transition.downToUp,
        page: () => const BookCreatePage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.bookOwnedPage,
        transition: Transition.rightToLeft,
        page: () => const BookOwnedPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.communityListPage,
        transition: Transition.noTransition,
        page: () => const CommunityListPage(),
      ),
      GetPage<bool>(
        name: RouteNames.communityCreatePage,
        transition: Transition.downToUp,
        page: () => const CommunityCreatePage(),
      ),
      GetPage<bool>(
        name: RouteNames.communitySpecificPage,
        transition: Transition.rightToLeft,
        page: () => const CommunitySpecificPage(),
      ),
      GetPage<bool>(
        name: RouteNames.communitySpecificBookPage,
        transition: Transition.rightToLeft,
        page: () => const CommunitySpecificBookPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.communityInvitePage,
        transition: Transition.downToUp,
        page: () => const CommunityInvitePage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.communityMembersPage,
        transition: Transition.downToUp,
        page: () => const CommunityMembersPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.invitationsPage,
        transition: Transition.noTransition,
        page: () => const InvitationsPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.loansPage,
        transition: Transition.noTransition,
        page: () => const LoansPage(),
      ),
    ];
