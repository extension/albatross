# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file
class AppUrlRewriteLog < ActiveRecord::Base
  belongs_to :app_url_rewrite
  has_one :application, through: :app_url_rewrite
end
