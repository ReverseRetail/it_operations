# frozen_string_literal: true

# == Schema Information
#
# Table name: it_operations
#
#  id           :bigint           not null, primary key
#  arguments    :string
#  entity_class :string           not null
#  operation    :string
#  processed    :boolean          default(FALSE), not null
#  result       :text
#  successful   :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  entity_id    :integer
#
# Indexes
#
#  index_it_operations_on_operation  (operation)
#

module ItOperations
  class ItOperation < ActiveRecord::Base
    scope :processed,    -> { where(processed: true)  }
    scope :unprocessed,  -> { where(processed: false) }
    scope :unsuccessful, -> { where(successful: false) }
    scope :successful,   -> { where(successful: true) }
    scope :by_op, ->(operation) { where(operation: operation) }

    def klass
      entity_class.constantize
    end

    def entity
      klass.find(entity_id)
    end

    def mark_successful(msg = nil)
      self.processed = true
      self.successful = true
      self.result = msg
    end

    def mark_successful!(msg = nil)
      mark_successful(msg)
      save!
    end

    def mark_failed(msg = nil)
      self.processed = true
      self.successful = false
      self.result = msg
    end

    def mark_failed!(msg = nil)
      mark_failed(msg)
      save!
    end
  end
end
