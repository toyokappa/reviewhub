class SyncReposAndPullsJob < ApplicationJob
  queue_as :default

  def perform(user)
    github_user = Octokit::Client.new(access_token: user.access_token, per_page: 100)
    github_user.login
    github_user.repos({}, query: { type: "owner" }).each do |github_repo|
      repo = user.repos.find_by(id: github_repo.id)
      if repo
        repo.sync!(github_repo)
      else
        repo = user.create_repo!(github_repo)
      end

      github_user.pulls(repo.id, state: "all").each do |github_pull|
        next if github_pull.blank?

        pull = repo.pulls.find_by(id: github_pull.id)
        if pull
          pull.sync!(github_pull)
        else
          repo.create_pull!(github_pull)
        end
      end
    end
  end
end