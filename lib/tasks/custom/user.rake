# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

require_relative '../task_helpers'

namespace :user do
  batch_size = 500
  
  desc 'set user password same as email'
  task :restusers, [:provider] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')
    has_encountred_issue = 0

    User.where(external_id: nil, provider: args[:provider])
    .find_each(batch_size:) do |user|
      user.update_attribute(:password,user.email)
      has_encountred_issue +=1;
      puts  "Successfully migrated User: #{user.email}"
    end

    puts
    puts  "#{has_encountred_issue} Users migration completed."
    exit 0
  end

  private

  def check_role!(user:)
    role_name = user[:role]
    user[:role] = Role.find_by(name: role_name, provider: 'greenlight')
    return if user[:role]

    warning "Unable to create user: '#{user[:name]}'"
    err "   Role '#{role_name}' does not exist, maybe you have not run the DB migrations?"
  end

  def display_user_errors(user:)
    warning "Unable to create user: '#{user.name}'"
    err "   Failed to pass the following validations:\n    #{user.errors.to_a}"
  end
end
