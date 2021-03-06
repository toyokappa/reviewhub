# == Schema Information
#
# Table name: review_requests
#
#  id          :bigint(8)        not null, primary key
#  name        :string(255)
#  description :text(65535)
#  is_open     :boolean          default(TRUE), not null
#  state       :integer          default("wait_review"), not null
#  pull_id     :integer
#  reviewee_id :integer
#  room_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ReviewRequest < ApplicationRecord
  extend Enumerize

  belongs_to :pull, inverse_of: :review_requests
  belongs_to :reviewee, class_name: "User", inverse_of: :review_requests
  belongs_to :room, inverse_of: :review_assigns

  enumerize :state, in: [:wait_review, :commented, :changes_requested, :approved, :resolved], predicates: true

  def state_color
    case state.to_sym
    when :wait_review
      "info"
    when :commented
      "grey"
    when :changes_requested
      "warning"
    when :approved
      "success"
    when :resolved
      "accent"
    end
  end
end
