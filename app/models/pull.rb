class Pull < ApplicationRecord
  belongs_to :repo, inverse_of: :pulls
  has_many :review_requests, dependent: :destroy, inverse_of: :pull

  # NOTE: ユーザーが後ほど変更できうる値にバリデーションを掛ける
  validates :name, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 10000 }
  validates :is_open, inclusion: { in: [true, false] }

  def sync!(github_pull)
    github_pull_state = github_pull.state == "open"
    update!(
      name: github_pull.title,
      description: github_pull.body,
      url: github_pull.html_url,
      is_open: github_pull_state,
    )
  end
end