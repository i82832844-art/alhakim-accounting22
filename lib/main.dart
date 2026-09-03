import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/product_repository.dart';
import 'services/sales_repository.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlHakimApp());
}

class AlHakimApp extends StatelessWidget {
  const AlHakimApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepository>(create: (_) => ProductRepository()),
        Provider<SalesRepository>(create: (_) => SalesRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'الحكيم للمحاسبة',
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        home: const _Shell(),
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;
  final _pages = const [DashboardScreen(), SalesScreen(), ProductsScreen()];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _pages[_index],
        floatingActionButton: _index == 0
            ? FloatingActionButton.small(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())), child: const Icon(Icons.qr_code_scanner))
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'المبيعات'),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'المخزون'),
          ],
        ),
      ),
    );
  }
}
