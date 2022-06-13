# see: https://github.com/mperham/sidekiq/wiki/Kubernetes#health-checks
SIDEKIQ_WILL_PROCESSES_JOBS_FILE = Rails.root.join("tmp/sidekiq_process_has_started_and_will_begin_processing_jobs").freeze

Sidekiq.configure_server do |config|
  # We touch and destroy files in the Sidekiq lifecycle to provide a
  # signal to Kubernetes that we are ready to process jobs or not.
  #
  # Doing this gives us a better sense of when a process is actually
  # alive and healthy, rather than just beginning the boot process.
  config.on(:startup) do
    FileUtils.touch(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end

  config.on(:shutdown) do
    FileUtils.rm_f(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end
end
