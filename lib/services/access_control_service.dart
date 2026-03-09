class AccessControlService {
  static const String roleChairman = 'Ketua';
  static const String roleMember = 'Anggota';
  static const String roleAssistant = 'Asisten';

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static final Map<String, List<String>> _rolePermissions = {
    roleChairman: [actionCreate, actionRead, actionUpdate, actionDelete],
    roleMember: [actionCreate, actionRead],
    roleAssistant: [actionRead, actionUpdate],
  };

  static List<String> get availableRoles => _rolePermissions.keys.toList();

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    final permissions = _rolePermissions[role] ?? [];
    bool hasBasicPermission = permissions.contains(action);

    return hasBasicPermission;
  }

  static bool canView(String role, String authorId, String currentUserId, bool isPublic) {
    final isOwner = authorId == currentUserId;
    return isOwner || isPublic;
  }

  static bool canEdit(String role, String authorId, String currentUserId) {
    final isOwner = authorId == currentUserId;
    return isOwner;
  }

  static bool canDelete(String role, String authorId, String currentUserId) {
    final isOwner = authorId == currentUserId;
    return isOwner;
  }

  static bool canCreate(String role) {
    return canPerform(role, actionCreate);
  }
}
