# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class AppLocation < ActiveRecord::Base
  attr_accessible :application, :application_id, :location, :url, :dbname

  belongs_to :application
  has_many :deploys

  PRODUCTION = 'production'
  STAGING = 'staging'

  scope :production, where(location: 'production')
  scope :active, includes(:application).where("applications.is_active = 1")


  def latest_deploy
    self.deploys.order('finish DESC').first
  end

  def display_url
    begin
      uri = URI.parse(self.url)
      uri.host
    rescue
      self.url
    end
  end

  def host
    begin
      uri = URI.parse(self.url)
      uri.host
    rescue
      self.url
    end
  end


  def check_maintenance
    headers = {'User-Agent' => 'engineering maintenance verification'}
    # the URL should have likely already be validated, but let's do it again for good measure
    begin
      check_uri = URI.parse("#{self.url}")
    rescue Exception => exception
      return false
    end

    if(check_uri.scheme != 'http' and check_uri.scheme != 'https')
      return false
    end

    # check it!
    begin
      response = nil
      http_connection = Net::HTTP.new(check_uri.host, check_uri.port)
      if(check_uri.scheme == 'https')
        # don't verify cert?
        http_connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http_connection.use_ssl = true
      end
      request_path = !check_uri.path.blank? ? check_uri.path : "/"
      if(!check_uri.query.blank?)
        request_path += "?" + check_uri.query
      end

      response = http_connection.head(request_path,headers)
      if(response.code == "503")
        return true
      else
        return false
      end
    rescue Exception => exception
      return false
    end
  end

end
