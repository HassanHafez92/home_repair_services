class ServiceCategories {
  static const String plumbing = 'plumbing';
  static const String electrical = 'electrical';
  static const String ac = 'ac';
  static const String carpentry = 'carpentry';
  
  static const List<String> availableServices = [
    plumbing,
    electrical,
    ac,
    carpentry
  ];
  
  static String getDisplayName(String key) {
    switch (key) {
      case plumbing:
        return 'Plumbing';
      case electrical:
        return 'Electrical';
      case ac:
        return 'HVAC / AC';
      case carpentry:
        return 'Carpentry';
      default:
        return 'General Service';
    }
  }
}
