#!/usr/bin/ruby -w
# By Paul Kim 4/27/2017
# ClassTwist Inc. 2017
# ClassDojo

# http://docs.buddybuild.com/docs/custom-prebuild-and-postbuild-steps

require 'net/http'
require 'uri'
require 'json'

ACCESS_TOKEN = "ENTER ACCESS TOKEN HERE"

CURRENT_SCHEME = ENV["BUDDYBUILD_SCHEME"]
CURRENT_BRANCH = ENV["BUDDYBUILD_BRANCH"]
CURRENT_BUILD_ID = ENV["BUDDYBUILD_BUILD_ID"]

def add_param(url, param_name, param_value)
  uri = URI(url)
  params = URI.decode_www_form(uri.query || "") << [param_name, param_value]
  uri.query = URI.encode_www_form(params)
  uri.to_s
end

class Request

  def self.get_request(url) 
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field('Authorization', "Bearer " + ACCESS_TOKEN)
    return request
  end

  def self.post_request(url)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.add_field('Authorization', "Bearer " + ACCESS_TOKEN)
    request.add_field('Content-Type', 'application/json')
    return request
  end
end

class BuddyBuild

  def self.list_apps()
    url = "https://api.buddybuild.com/v1/apps"

    req = Request.get_request(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)
  end

  def self.list_branches(app_id, includeDeleted=false)
    url = "https://api.buddybuild.com/v1/apps/#{app_id}/branches"

    add_param(url, "includeDeleted", includeDeleted)

    req = Request.get_request(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)
  end

  def self.list_builds(app_id, branch=nil, scheme=nil, status=nil, limit=nil)
    url = "https://api.buddybuild.com/v1/apps/#{app_id}/builds"

    unless branch.nil?
      url = add_param(url, "branch", branch)
    end

    unless scheme.nil?
      url = add_param(url, "scheme", scheme)
    end

    unless status.nil?
      url = add_param(url, "status", status)
    end

    unless limit.nil?
      url = add_param(url, "limit", limit)
    end

    req = Request.get_request(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)

  end

  def self.get_latest_status(app_id, branch=nil, scheme=nil, status=nil)

    url = "https://api.buddybuild.com/v1/apps/#{app_id}/build/latest"

    unless branch.nil?
      url = add_param(url, "branch", branch)
    end

    unless scheme.nil?
      url = add_param(url, "scheme", scheme)
    end

    unless status.nil?
      url = add_param(url, "status", status)
    end

    req = Request.get_request(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)

  end

  def self.get_build_status(build_id) 

    url = "https://api.buddybuild.com/v1/builds/#{build_id}"

    req = Request.get_request(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)
  end

  def self.get_test_results(build_id, showFailed=nil, showPassing=nil) 

    url = "https://api.buddybuild.com/v1/builds/#{build_id}/tests"

    unless showFailed.nil?
      url = add_param(url, "showFailed", showFailed)
    end

    unless showPassing.nil?
      url = add_param(url, "showPassing", showPassing)
    end

    req = Request.get_request(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)
  end

  def self.trigger_build(app_id, branch)

    url = "https://api.buddybuild.com/v1/apps/#{app_id}/build"
    request = Request.post_request(url)

    if branch.nil?
      puts "Triggering build for appId: #{app_id}"
    else
      puts "Triggering build for appId: #{app_id} and branch: #{branch}"
      request.body = {branch: branch}.to_json
    end

    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(request)

    res_json = JSON.parse(res.body)
    created_build_id = res_json["build_id"]

    unless created_build_id.nil?
      puts "Successfully triggered build with id #{created_build_id}"  
    end

    return created_build_id

  end

end
