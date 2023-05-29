import 'package:biblioteca/presentation/community/community_invite/community_invite_page.dart';
import 'package:biblioteca/presentation/community/community_list_page.dart';
import 'package:biblioteca/presentation/community/community_create/community_create_page.dart';
import 'package:biblioteca/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:biblioteca/presentation/community/community_specific/community_specific_page.dart';
import 'package:biblioteca/presentation/invitations/invitations_page.dart';
import 'package:biblioteca/presentation/login/login_page.dart';
import 'package:biblioteca/presentation/book/book_create/book_create_page.dart';
import 'package:biblioteca/presentation/book/book_owned/book_owned_page.dart';
import 'package:biblioteca/presentation/book/book_list_page.dart';
import 'package:biblioteca/presentation/register/register_page.dart';
import 'package:biblioteca/presentation/start/start_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class RouteNames {
  static const startPage = '/start';
  static const loginPage = '/login';
  static const registerPage = '/register';
  static const dashboardPage = '/dashboard';
  static const bookListPage = '/book';
  static const bookCreatePage = '/book/create';
  static const bookOwnedPage = '/book/owned';
  static const communityListPage = '/community';
  static const communityCreatePage = '/community/create';
  static const communitySpecificPage = '/community/specific';
  static const communityInvitePage = '/community/invite';
  static const communityMembersPage = '/community/members';
  static const invitationsPage = '/invitations';
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
    ];
