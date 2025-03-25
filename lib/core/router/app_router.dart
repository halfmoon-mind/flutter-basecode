import 'package:go_router/go_router.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/home/view/home_screen.dart';

GoRouter goRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
