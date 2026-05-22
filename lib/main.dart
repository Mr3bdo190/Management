import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/factory_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // التأكد من تهيئة الفلاتر قبل تشغيل أي شيء
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // محاولة تشغيل الفيربيز
    await Firebase.initializeApp();
  } catch (e) {
    print('تنبيه: الفيربيز يحتاج ملف الإعدادات google-services.json $e');
  }

  runApp(const FactoryApp());
}

class FactoryApp extends StatelessWidget {
  const FactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FactoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'إدارة المصنع',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        // إجبار التطبيق بالكامل على استخدام اتجاه من اليمين لليسار (عربي)
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}
