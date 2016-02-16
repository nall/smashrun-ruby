# vim: filetype=ruby shiftwidth=2 tabstop=2 expandtab
#
# Copyright (c) 2016, Jon Nall
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of tradervue-utils nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'date'
require 'oauth2'
require 'json'

class Smashrun
  ID = 'id'
  BRIEF = 'brief'
  FULL = 'full'

  def initialize(client_id, client_secret, token=nil, refresh_token=nil)
    @client_id = client_id
    @client_secret = client_secret
    @base_url = 'https://api.smashrun.com/v1'

    oauth_params = { :site => 'https://api.smashrun.com',
            :authorize_url => 'https://secure.smashrun.com/oauth2/authenticate',
                :token_url => 'https://secure.smashrun.com/oauth2/token' }
    @oauth = OAuth2::Client.new(@client_id, @client_secret, oauth_params)

    if not token.nil?
      @token = OAuth2::AccessToken.from_hash(@oauth, {:access_token => token, :refresh_token => refresh_token})
    end
  end

  def get_auth_url(scope='read_activity', redirect_uri='urn:ietf:wg:oauth:2.0:oob')
    return @oauth.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => scope)
  end

  def get_token(code)
    @token = @oauth.auth_code.get_token(code)
    return @token.token
  end

  def get_refresh_token()
    raise "No valid token found for client" if @token.nil?
    return @token.refresh_token
  end

  def revoke_token(token=nil, all_tokens=false)
    raise "revoke_token isn't implemented yet"
  end

  def token_status()
    raise "No valid token found for client" if @token.nil?

    components = ['v1', 'auth', @token.token]
    s = @token.get(components.join('/'))
    if s.status == 200
      return JSON.parse(s.body)
    else
      return nil
    end
  end

  def activities(options={})
    defaults = { :activity_id => nil, :count => nil, :page => nil, :fromDate => nil, :level => nil }
    options = defaults.merge(options)

    raise "No valid token found for client" if @token.nil?
    raise "Page can't be specified without a count" if not options[:page].nil? and options[:count].nil?

    # Don't allow searching options if activity_id is specified
    raise "fromDate not allowed with activity_id" if not options[:activity_id].nil? and not options[:fromDate].nil?
    raise "level not allowed with activity_id" if not options[:activity_id].nil? and not options[:level].nil?
    raise "page not allowed with activity_id" if not options[:activity_id].nil? and not options[:page].nil?
    raise "count not allowed with activity_id" if not options[:activity_id].nil? and not options[:count].nil?

    # Allow fromDate to be a date or a string/int representing epoch secs
    fromDate = options[:fromDate]
    if fromDate.is_a? Date or fromDate.is_a? DateTime
      fromDate = fromDate.to_time.utc.to_i
    end

    params = {}
    params[:page] = options[:page] unless options[:page].nil?
    params[:count] = options[:count] unless options[:count].nil?
    params[:fromDate] = fromDate.to_s unless fromDate.nil?

    components = ['v1', 'my', 'activities']
    if not options[:activity_id].nil?
      components << options[:activity_id]
    else
      components << 'search'
      components << 'ids' if options[:level].nil? or options[:level] == ID
      components << 'briefs' if options[:level] == BRIEF
    end

    s = @token.get(components.join('/'), {:params => params})
    if s.status == 200
      return JSON.parse(s.body)
    else
      return nil
    end
  end

  def weights(latest=false)
    raise "No valid token found for client" if @token.nil?

    components = ['v1', 'my', 'body', 'weight']
    components << 'latest' if latest

    s = @token.get(components.join('/'))
    if s.status == 200
      return JSON.parse(s.body)
    else
      return nil
    end
  end

  def userinfo()
    raise "No valid token found for client" if @token.nil?

    components = ['v1', 'my', 'userinfo']
    s = @token.get(components.join('/'))
    if s.status == 200
      return JSON.parse(s.body)
    else
      return nil
    end
  end

  def badges(new=false)
    raise "No valid token found for client" if @token.nil?

    components = ['v1', 'my', 'badges']
    components << 'new' if new

    s = @token.get(components.join('/'))
    if s.status == 200
      return JSON.parse(s.body)
    else
      return nil
    end
  end

  def stats(year=nil, month=nil)
    raise "No valid token found for client" if @token.nil?
    raise "Must specify a non-nil year if month is not nil" if year.nil? and not month.nil?

    components = ['v1', 'my', 'stats']
    components << year.to_s unless year.nil?
    components << month.to_s unless month.nil?

    s = @token.get(components.join('/'))
    if s.status == 200
      return JSON.parse(s.body)
    else
      return nil
    end
  end

end

