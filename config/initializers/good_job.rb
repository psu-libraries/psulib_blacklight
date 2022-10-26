# frozen_string_literal: true

Rails.application.configure do
  config.good_job.cron = {
    clean_search: {
      cron: '0 2 * * *',
      class: 'CleanSearchesJob',
      kwargs: { days_old: 90 }
    }
  }
end
