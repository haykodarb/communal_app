import 'package:biblioteca/presentation/dashboard/dashboard_page.dart';
import 'package:biblioteca/presentation/login/login_page.dart';
import 'package:biblioteca/presentation/mybooks/addbook/addbook_page.dart';
import 'package:biblioteca/presentation/mybooks/book/ownedbook_page.dart';
import 'package:biblioteca/presentation/mybooks/mybooks_page.dart';
import 'package:biblioteca/presentation/register/register_page.dart';
import 'package:biblioteca/presentation/start/start_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class RouteNames {
  static const startPage = '/start';
  static const loginPage = '/login';
  static const registerPage = '/register';
  static const dashboardPage = '/dashboard';
  static const myBooksPage = '/mybooks';
  static const addBookPage = '/mybooks/add';
  static const ownedBookPage = '/mybooks/book';
  static const communitiesPage = '/communities';
  static const manageCommunitiesPage = '/communities/manage';
  static const createCommunityPage = '/communities/create';
  static const joinCommunityPage = '/communities/join';
  static const inviteCommunityPage = '/communities/invite';
}

List<GetPage> routes() => <GetPage>[
      GetPage<dynamic>(
        name: RouteNames.startPage,
        transition: Transition.noTransition,
        page: () => StartPage(),
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
        page: () => RegisterPage(),
        transition: Transition.downToUp,
        transitionDuration: const Duration(
          milliseconds: 300,
        ),
      ),
      GetPage<dynamic>(
        name: RouteNames.dashboardPage,
        transition: Transition.noTransition,
        page: () => const DashboardPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.myBooksPage,
        transition: Transition.noTransition,
        page: () => const MyBooksPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.addBookPage,
        transition: Transition.downToUp,
        page: () => const AddBookPage(),
      ),
      GetPage<dynamic>(
        name: RouteNames.ownedBookPage,
        transition: Transition.downToUp,
        page: () => const OwnedBookPage(),
      ),
    ];
