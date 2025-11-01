import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://rsojjwyogfmboswyhkzm.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzb2pqd3lvZ2ZtYm9zd3loa3ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MDU0OTksImV4cCI6MjA3NzM4MTQ5OX0.F0Mmfzxh2wX-TCndp-CjCwnL7npIHPWMfk7Pn3IxcGU';

SupabaseClient get supabase => Supabase.instance.client;
