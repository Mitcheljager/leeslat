ActiveStorage::AnalyzeJob.queue_adapter = :async
ActiveStorage::PurgeJob.queue_adapter = :async
ActiveStorage::TransformJob.queue_adapter = :async
ActiveStorage::Attach::CreateManyJob.queue_adapter = :async
ActiveStorage::Attach::DetachManyJob.queue_adapter = :async
