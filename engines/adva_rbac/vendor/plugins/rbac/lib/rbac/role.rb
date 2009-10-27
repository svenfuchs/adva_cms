module Rbac
  class Role < ActiveRecord::Base
    belongs_to :subject, :polymorphic => true
    belongs_to :context, :polymorphic => true

    def has_context?
      context_type && context_id
    end
  end
end