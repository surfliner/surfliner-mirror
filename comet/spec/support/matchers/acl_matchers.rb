RSpec::Matchers.define :grant_access do |expected_acl_mode|
  match do |actual_acl|
    matches = actual_acl.permissions.select do |p|
      p.mode.to_sym == expected_acl_mode &&
        (expected_resource.nil? || (p.access_to == expected_resource.id)) &&
        (expected_agent.nil? || p.agent.end_with?(expected_agent.name))
    end

    matches.any?
  end

  chain :on, :expected_resource
  chain :to, :expected_agent
end

RSpec::Matchers.define :revoke_access do |expected_acl_mode|
  match do |actual_acl|
    matches = actual_acl.permissions.select do |p|
      p.mode.to_sym == expected_acl_mode &&
        (expected_resource.nil? || (p.access_to == expected_resource.id)) &&
        (expected_agent.nil? || p.agent.end_with?(expected_agent.name))
    end

    matches.empty?
  end

  chain :on, :expected_resource
  chain :from, :expected_agent
end
