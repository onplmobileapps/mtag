import '../../features/design/home_page.dart';
import '../../features/recharge_center_locator.dart';
import '../../widgets/new_bottom_bar.dart';
import '../settings/setting_screen.dart';

final navItems = [
  BottomNavItem(
    imagePath: 'assets/home_new.svg',
    label: 'Home',
    index: 0,
    page: HomePageContent(),
  ),
  BottomNavItem(
    imagePath: 'assets/weather.svg',
    label: 'Weather Update',
    index: 1,
    page: HomePageContent(),
  ),
  BottomNavItem.spacer(),
  BottomNavItem(
    imagePath: 'assets/location.svg',
    label: 'Recharge Centers',
    index: 2,
    page: RechargeMapScreen(),
  ),
  BottomNavItem(
    imagePath: 'assets/user.svg',
    label: 'Profile',
    index: 3,
    page: SettingScreen(),
  ),
];
