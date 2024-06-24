# frozen_string_literal: true

namespace :blacklight do
  # task to clean out old, unsaved searches
  # overrides blacklight task to delete searches in batches
  desc 'Removes entries in the searches table that are older than the number of days given.'
  task :delete_old_searches, [:days_old, :batch_size] => [:environment] do |_t, args|
    args.with_defaults(days_old: 7, batch_size: 1000)
    Search
      .where('created_at < ? AND user_id IS NULL', Time.zone.today - args[:days_old].to_i)
      .find_each(batch_size: args[:batch_size], &:destroy)
  end
end
