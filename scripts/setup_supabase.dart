#!/usr/bin/env dart
/// Automated Supabase Setup Script
/// 
/// This script automates the setup of Supabase database tables, policies, and functions.
/// It can be run from the command line with Supabase credentials.
/// 
/// Usage:
///   dart scripts/setup_supabase.dart --url <SUPABASE_URL> --key <SERVICE_ROLE_KEY>
///   
/// Or with environment variables:
///   SUPABASE_URL=<url> SUPABASE_SERVICE_KEY=<key> dart scripts/setup_supabase.dart

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🚀 Supabase Automated Setup');
  print('=' * 50);

  // Parse arguments or environment variables
  final config = _parseConfig(args);
  
  if (config == null) {
    print('❌ Error: Missing required configuration');
    print('');
    print('Usage:');
    print('  dart scripts/setup_supabase.dart --url <SUPABASE_URL> --key <SERVICE_ROLE_KEY>');
    print('');
    print('Or set environment variables:');
    print('  SUPABASE_URL=<url>');
    print('  SUPABASE_SERVICE_KEY=<key>');
    exit(1);
  }

  print('📍 Supabase URL: ${config['url']}');
  print('');

  // Read migration files
  final migrations = await _loadMigrations();
  
  if (migrations.isEmpty) {
    print('⚠️  No migration files found');
    exit(0);
  }

  print('📦 Found ${migrations.length} migration(s)');
  print('');

  // Execute migrations
  var successCount = 0;
  var failCount = 0;

  for (var i = 0; i < migrations.length; i++) {
    final migration = migrations[i];
    print('[${ i + 1}/${migrations.length}] Running: ${migration['name']}');
    
    final success = await _executeMigration(
      config['url']!,
      config['key']!,
      migration['sql']!,
    );

    if (success) {
      print('  ✅ Success');
      successCount++;
    } else {
      print('  ❌ Failed');
      failCount++;
    }
    print('');
  }

  // Summary
  print('=' * 50);
  print('📊 Summary:');
  print('  ✅ Successful: $successCount');
  print('  ❌ Failed: $failCount');
  print('');

  if (failCount == 0) {
    print('🎉 All migrations completed successfully!');
    print('');
    print('Next steps:');
    print('  1. Enable email authentication in Supabase dashboard');
    print('  2. Update app_constants.dart with your credentials');
    print('  3. Run the app: flutter run');
    exit(0);
  } else {
    print('⚠️  Some migrations failed. Please check the errors above.');
    exit(1);
  }
}

Map<String, String>? _parseConfig(List<String> args) {
  String? url;
  String? key;

  // Try command line arguments first
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--url' && i + 1 < args.length) {
      url = args[i + 1];
    } else if (args[i] == '--key' && i + 1 < args.length) {
      key = args[i + 1];
    }
  }

  // Fall back to environment variables
  url ??= Platform.environment['SUPABASE_URL'];
  key ??= Platform.environment['SUPABASE_SERVICE_KEY'];

  if (url == null || key == null) {
    return null;
  }

  return {'url': url, 'key': key};
}

Future<List<Map<String, String>>> _loadMigrations() async {
  final migrationsDir = Directory('scripts/migrations');
  
  if (!await migrationsDir.exists()) {
    return [];
  }

  final files = await migrationsDir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.sql'))
      .cast<File>()
      .toList();

  // Sort by filename (assuming numbered migrations like 001_initial.sql)
  files.sort((a, b) => a.path.compareTo(b.path));

  final migrations = <Map<String, String>>[];
  
  for (final file in files) {
    final name = file.path.split(Platform.pathSeparator).last;
    final sql = await file.readAsString();
    migrations.add({'name': name, 'sql': sql});
  }

  return migrations;
}

Future<bool> _executeMigration(String url, String key, String sql) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse('$url/rest/v1/rpc/exec_sql');
    
    final request = await client.postUrl(uri);
    request.headers.set('apikey', key);
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('Content-Type', 'application/json');
    
    // For Supabase, we need to execute SQL via the REST API
    // This is a simplified version - in production, you'd use the Management API
    final body = jsonEncode({'query': sql});
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    client.close();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      print('  Error: ${response.statusCode}');
      print('  Response: $responseBody');
      return false;
    }
  } catch (e) {
    print('  Exception: $e');
    return false;
  }
}
