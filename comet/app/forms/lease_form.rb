class LeaseForm < Hyrax::ChangeSet
  property :visibility_after_lease
  property :visibility_during_lease
  property :lease_expiration_date
  property :lease_history, default: []
end
