class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  rescue_from(StandardError) do |error|
    named_error = error.exception("#{error.message} (job: #{self.class.name})")
    ExceptionNotifier.notify_exception(named_error)
    raise error
  end
end
