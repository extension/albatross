# === COPYRIGHT:
# Copyright (c) 2014 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'open3'

class GitFetch < ActiveRecord::Base
  belongs_to :application

  def repository
    match = self.application.github_url.match(%r{^https://github.com/(?<account>\w+)/(?<reponame>\w+)})
    if(match and match['reponame'])
      "#{match['reponame']}.git"
    else
      nil
    end
  end


  def clone_url
    match = self.application.github_url.match(%r{^https://github.com/(?<account>\w+)/(?<reponame>\w+)})
    if(match and match['account'] and match['reponame'])
      "git@github.com:#{match['account']}/#{match['reponame']}.git"
    else
      nil
    end
  end

  def self.fetch_from_github(application)
    fetcher = self.new(application: application)
    if(fetcher.repository and fetcher.clone_url)
      repository_parent = "#{Rails.root}/repositories"
      repository_path = "#{repository_parent}/#{fetcher.repository}"
      fetch_command = "git fetch --verbose --all --prune"
      clone_command = "git clone --verbose --mirror #{fetcher.clone_url}"

      if(File.exists?(repository_path))
        Dir.chdir(repository_path)
        fetcher.command = fetch_command
      else
        Dir.chdir(repository_parent)
        fetcher.command = clone_command
      end

      fetcher.started_at = Time.now.utc
      stdin, stdout, stderr = Open3.popen3(fetcher.command)
      stdin.close
      fetcher.stdout = stdout.read
      fetcher.stderr = stderr.read
      fetcher.finished_at = Time.now.utc
      fetcher.runtime = fetcher.finished_at - fetcher.started_at
      fetcher.save
      fetcher.application.update_attribute(:fetch_pending, false)
      fetcher
    else
      nil
    end
  end

end
