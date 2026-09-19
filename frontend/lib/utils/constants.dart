class AppConstants {
  static const String appName = 'Farm-to-Market';

  static const String supabaseUrl =
      'https://dadwtiqesdswqriqayay.supabase.co';

  static const String supabaseAnonKey =
      'sb_publishable_adrXJotOc7bvHDmY8kYEdQ_M7An6tOp';

  static const String roleFarmer = 'farmer';
  static const String roleRetailer = 'retailer';
  static const String roleAdmin = 'admin';

  static const List<String> publicRegistrationRoles = [
    roleFarmer,
    roleRetailer,
  ];
}
