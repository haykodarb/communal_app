import 'package:communal/presentation/book/book_edit/book_edit_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_create/community_discussions_topic_create_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_messages/community_discussions_topic_messages_page.dart';
import 'package:communal/presentation/community/community_specific/community_settings/community_settings_page.dart';
import 'package:communal/presentation/loans/loan_info/loan_info_page.dart';
import 'package:communal/presentation/login/login_password_recovery/login_password_recovery_page.dart';
import 'package:communal/presentation/messages/messages_page.dart';
import 'package:communal/presentation/community/community_invite/community_invite_page.dart';
import 'package:communal/presentation/community/community_list_page.dart';
import 'package:communal/presentation/community/community_create/community_create_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_page.dart';
import 'package:communal/presentation/invitations/invitations_page.dart';
import 'package:communal/presentation/loans/loans_page.dart';
import 'package:communal/presentation/login/login_page.dart';
import 'package:communal/presentation/book/book_create/book_create_page.dart';
import 'package:communal/presentation/book/book_owned/book_owned_page.dart';
import 'package:communal/presentation/book/book_list_page.dart';
import 'package:communal/presentation/messages/messages_specific/messages_specific_page.dart';
import 'package:communal/presentation/notifications/notifications_page.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_page.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_edit/profile_own_edit_page.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_page.dart';
import 'package:communal/presentation/register/register_page.dart';
import 'package:communal/presentation/register/register_resend/register_resend_page.dart';
import 'package:communal/presentation/start/start_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class RouteNames {
  static const String startPage = '/start';

  static const String loginPage = '/login';
  static const String loginRecoveryPage = '/login/recovery';

  static const String registerPage = '/register';
  static const String registerResendPage = '/register/resend';

  static const String profileOwnPage = '/profile/own';
  static const String profileOwnEditPage = '/profile/own/edit';
  static const String profileOtherPage = '/profile/other';

  static const String bookListPage = '/book';
  static const String bookCreatePage = '/book/create';
  static const String bookOwnedPage = '/book/owned';
  static const String bookEditPage = '/book/edit';

  static const String toolListPage = '/tool';
  static const String toolCreatePage = '/tool/create';
  static const String toolOwnedPage = '/tool/owned';
  static const String toolEditPage = '/tool/edit';

  static const String communityListPage = '/community';
  static const String communityCreatePage = '/community/create';
  static const String communitySpecificPage = '/community/specific';
  static const String communitySettingsPage = '/community/settings';
  static const String communitySpecificBookPage = '/community/specific/book';
  static const String communitySpecificToolPage = '/community/specific/tool';
  static const String communityInvitePage = '/community/invite';
  static const String communityDiscussionsTopicCreate = '/community/discussions/topic/create';
  static const String communityDiscussionsTopicMessages = '/community/discussions/topic/messages';

  static const String invitationsPage = '/invitations';

  static const String loansPage = '/loans';
  static const String loanInfoPage = '/loans/info';

  static const String messagesPage = '/messages';
  static const String messagesSpecificPage = '/messages/specific';

  static const String notificationsPage = '/notifications';
}

final List<GetPage> routes = <GetPage>[
  GetPage<dynamic>(
    name: RouteNames.startPage,
    transition: Transition.noTransition,
    page: () => const StartPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.loginPage,
    page: () => const LoginPage(),
    transition: Transition.noTransition,
  ),
  GetPage<dynamic>(
    name: RouteNames.loginRecoveryPage,
    page: () => const LoginPasswordRecoveryPage(),
    transition: Transition.noTransition,
  ),
  GetPage<dynamic>(
    name: RouteNames.registerPage,
    page: () => const RegisterPage(),
    transition: Transition.noTransition,
  ),
  GetPage<dynamic>(
    name: RouteNames.registerResendPage,
    page: () => const RegisterResendPage(),
    transition: Transition.noTransition,
  ),
  GetPage<dynamic>(
    name: RouteNames.bookListPage,
    transition: Transition.noTransition,
    page: () => const BookListPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.bookCreatePage,
    transition: Transition.noTransition,
    page: () => const BookCreatePage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.bookEditPage,
    transition: Transition.noTransition,
    page: () => const BookEditPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.bookOwnedPage,
    transition: Transition.noTransition,
    page: () => const BookOwnedPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.communityListPage,
    transition: Transition.noTransition,
    page: () => const CommunityListPage(),
  ),
  GetPage<bool>(
    name: RouteNames.communityCreatePage,
    transition: Transition.noTransition,
    page: () => const CommunityCreatePage(),
  ),
  GetPage<bool>(
    name: RouteNames.communitySpecificPage,
    transition: Transition.noTransition,
    page: () => const CommunitySpecificPage(),
  ),
  GetPage<bool>(
    name: RouteNames.communitySpecificBookPage,
    transition: Transition.noTransition,
    page: () => const CommunitySpecificBookPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.communityInvitePage,
    transition: Transition.noTransition,
    page: () => const CommunityInvitePage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.communityDiscussionsTopicCreate,
    transition: Transition.noTransition,
    page: () => const CommunityDiscussionsTopicCreatePage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.communityDiscussionsTopicMessages,
    transition: Transition.noTransition,
    page: () => const CommunityDiscussionsTopicMessagesPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.communitySettingsPage,
    transition: Transition.noTransition,
    page: () => const CommunitySettingsPage(),
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
  GetPage<dynamic>(
    name: RouteNames.loanInfoPage,
    transition: Transition.noTransition,
    page: () => const LoanInfoPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.messagesPage,
    transition: Transition.noTransition,
    page: () => const MessagesPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.messagesSpecificPage,
    transition: Transition.noTransition,
    page: () => const MessagesSpecificPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.profileOwnPage,
    transition: Transition.noTransition,
    page: () => const ProfileOwnPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.profileOwnEditPage,
    transition: Transition.noTransition,
    page: () => const ProfileOwnEditPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.profileOtherPage,
    transition: Transition.noTransition,
    page: () => const ProfileOtherPage(),
  ),
  GetPage<dynamic>(
    name: RouteNames.notificationsPage,
    transition: Transition.noTransition,
    page: () => const NotificationsPage(),
  ),
];
