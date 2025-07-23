# Force ActiveStorage jobs to use async instead of sidekiq
Rails.application.config.to_prepare do
  ActiveStorage::AnalyzeJob.queue_adapter = :async
  ActiveStorage::PurgeJob.queue_adapter = :async
  ActiveStorage::TransformJob.queue_adapter = :async
end
