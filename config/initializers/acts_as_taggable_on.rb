Rails.application.config.after_initialize do
    ActsAsTaggableOn.force_binary_collation = true
    ActsAsTaggableOn.remove_unused_tags = true
    ActsAsTaggableOn.force_lowercase = true
end