# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Deploy < ActiveRecord::Base
  include TimeUtils
  include MarkupScrubber
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host
  default_scope where("finish IS NOT NULL")


  attr_accessible :application, :coder, :capatross_id, :previous_revision, :deployed_revision, :location, :start, :finish, :success, :branch, :app_location_id
  belongs_to :application
  belongs_to :app_location
  belongs_to :coder
  has_one :deploy_log

  before_save :standardize_location, :set_app_location


  scope :byapplication, lambda{|application| where(:application_id => application.id)}
  scope :bylocation, lambda{|location| where(:location => location)}
  scope :bycoder, lambda{|coder| where(:coder_id => coder.id)}
  scope :production, where(location: 'production')
  scope :successful, where(success: true)
  scope :production_listing, successful.production.order('finish DESC')


  def deploy_time
    (self.finish - self.start)
  end


  # attr_writer override for comment to scrub html
  def comment=(commentcontent)
    write_attribute(:comment, self.cleanup_html(commentcontent))
  end

  def self.create_or_update_from_params(provided_params)
    if(!provided_params['appkey'] or !provided_params['capatross_id'] or !provided_params['deployer_email'])
      return nil
    end

    if(!(deploy = self.unscoped.find_by_capatross_id(provided_params['capatross_id'])))

      coder = Coder.find_by_deploy_email(provided_params['deployer_email'])
      if(!(application = Application.find_by_appkey(provided_params['appkey'])))
        return nil
      end

      deploy = Deploy.new(capatross_id: provided_params['capatross_id'], coder: coder, application: application)

    end

    deploy.previous_revision = provided_params['previous_revision']
    deploy.deployed_revision = provided_params['deployed_revision']
    deploy.location = provided_params['location']
    deploy.start = provided_params['start']
    deploy.finish = provided_params['finish']
    deploy.success = provided_params['success']
    deploy.comment = provided_params['comment']
    deploy.branch = provided_params['branch']
    deploy.uploaded = provided_params['from_cli']
    deploy.save!

    if(provided_params['deploy_log'])
      deploy_log = DeployLog.find_or_create_by_deploy(deploy)
      deploy_log.update_attribute(:output,provided_params['deploy_log'])
    end

    # notifications
    if(deploy.finish.nil?)
      Notification.create(notifiable: self, notification_type: Notification::DEPLOY_START)
    else
      Notification.create(notifiable: self, notification_type: Notification::DEPLOY_COMPLETE)    
    end

    deploy
  end

  def start_notification

    attachment = { "fallback" => "#{self.coder.name} started a #{self.location} of the #{self.branch} branch for #{self.application.name}.",
      "text" => "#{self.application.name.capitalize} #{self.location} deployment started",
      "fields" => [
        {
         "title" => "Who",
         "value" => "#{self.coder.name}",
         "short" => true
        },
        {
          "title" => "Branch",
          "value" =>  "#{self.branch}",
          "short" =>  true
        }
      ],
      "color" => "#f47B28"
    }

    SlackNotification.post({attachment: attachment, channel: "#testing", username: "Engineering Deploy Notification"})
  end


  def completed_notification
    if(self.uploaded?)
      _upload_notification
    elsif(self.success?)
      _success_notification
    else
      _failure_notification
    end
  end

  def _upload_notification

    # "meh" not a color code, falls back to default

    attachment = { "fallback" => "#{self.coder.name} uploaded a previous #{self.location} deployment log of the #{self.branch} branch for #{self.application.name}.",
    "text" => "#{self.application.name.capitalize} #{self.location} deployment uploaded",
    "fields" => [
      {
        "title" => "Who",
        "value" => "#{self.coder.name}",
        "short" => true
      },
      {
        "title" => "Branch",
        "value" =>  "#{self.branch}",
        "short" =>  true
      }
    ],
    "color" => "meh"
  }

  if(!self.comment.blank?)
    attachment["fields"].push({"title" => "Comments", "value" => self.comment, "short" => false})
  end

  attachment["fields"].push({"title" => "Details", "value" => self.notification_url, "short" => false})

  SlackNotification.post({attachment: attachment, channel: "#testing", username: "Engineering Deploy Notification"})
end


  def _success_notification

    attachment = { "fallback" => "#{self.coder.name} deployed the #{self.branch} branch of #{self.application.name} to #{self.location}. Details #{self.notification_url}.",
    "text" => "#{self.application.name.capitalize} #{self.location} deployment complete (Deploy time: #{time_period_to_s(self.deploy_time,true,'n/a')})",
    "fields" => [
      {
        "title" => "Who",
        "value" => "#{self.coder.name}",
        "short" => true
      },
      {
        "title" => "Branch",
        "value" =>  "#{self.branch}",
        "short" =>  true
      }
    ],
    "color" => "good"
  }

  if(!self.comment.blank?)
    attachment["fields"].push({"title" => "Comments", "value" => self.comment, "short" => false})
  end

  attachment["fields"].push({"title" => "Details", "value" => self.notification_url, "short" => false})

  SlackNotification.post({attachment: attachment, channel: "#testing", username: "Engineering Deploy Notification"})
end

def _failure_notification

    attachment = { "fallback" => "rotating_light: The #{self.location} deploy of the #{self.branch} branch of #{self.application.name} failed! Details #{self.notification_url} rotating_light:",
    "text" => ":rotating_light: #{self.application.name.capitalize} #{self.location} deployment FAILED! :rotating_light:",
    "fields" => [
      {
        "title" => "Who",
        "value" => "#{self.coder.name}",
        "short" => true
      },
      {
        "title" => "Branch",
        "value" =>  "#{self.branch}",
        "short" =>  true
      }
    ],
    "color" => "danger"
  }


  attachment["fields"].push({"title" => "Details", "value" => self.notification_url, "short" => false})

  SlackNotification.post({attachment: attachment, channel: "#testing", username: "Engineering Deploy Notification"})

end


  def self.coders_with_deploys
    Deploy.group(:coder).count
  end

  def self.applications_with_deploys
    Deploy.group(:application).count
  end

  def self.locations_with_deploys
    Deploy.group(:location).count
  end

  def standardize_location
    if(self.location == 'prod')
      self.location = 'production'
    elsif(self.location == 'dev')
      self.location = 'development'
    elsif(self.location == 'demo')
      self.location = 'development'
    end
  end

  def set_app_location
    if(app_location = application.app_location_for_location(self.location))
      self.app_location_id = app_location.id
    end
  end

  def notification_url
    deploy_url(self)
  end

  def set_branch_from_log
    if(self.deploy_log.output =~ %r{executing locally: "git ls-remote git@github.com:extension/(\w+)\.git (\w+)"})
      self.update_attribute(:branch, $2)
    end
  end

  def deployed_to_url
    if(self.app_location)
      self.app_location.url
    else
      nil
    end
  end


end
