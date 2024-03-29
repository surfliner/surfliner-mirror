# CometRoleMapper This is used by AccessControlsEnforcement to get users' Roles (used in access permissions)
# If you are using something like Shibboleth or LDAP to get users' Roles, you should override this Class.
# Your override should include a Module that implements the same behaviors as Hydra::RoleMapperBehavior
class CometRoleMapper < RoleMapper
  def self.fetch_groups(user:)
    super + (user.assigned_groups.nil? ? [] : user.assigned_groups.to_a)
  end
end
