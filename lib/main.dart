import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/data/marketplace_repository.dart';
import 'src/screens/marketplace_home_page.dart';
import 'src/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final hasSupabaseConfig =
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(NftMarketplaceApp(hasSupabaseConfig: hasSupabaseConfig));
}

class NftMarketplaceApp extends StatelessWidget {
  const NftMarketplaceApp({
    super.key,
    required this.hasSupabaseConfig,
  });

  final bool hasSupabaseConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFT Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MarketplaceHomePage(
        repository: MarketplaceRepository(
          useSupabase: hasSupabaseConfig,
        ),
      ),
    );
  }
}
