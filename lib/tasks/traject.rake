# frozen_string_literal: true

require 'psulib_blacklight/solr_manager'
require 'psulib_blacklight/data_manager'

require 'net/http'

namespace :traject do
  # We only run this task in kubernetes. Hide it if the WEBHOOK_URL is not set
  if ENV['TRAJECT_WEBHOOK_URL']
    desc 'Creates a new collection, then fires off traject job to index into that collection'
    task :iterate_and_import, [:path] => [:environment] do |_task, args|
      path = args['path'] || 'full_extracts'
      traject_webhook_url = ENV['TRAJECT_WEBHOOK_URL'] || raise('TRAJECT_WEBHOOK_URL is missing')
      uri = URI("http://#{traject_webhook_url}/traject")
      solr_manager.create_collection
      collection = solr_manager.last_incremented_collection

      puts "Asking Traject to index #{path} to #{collection}"

      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { collection: collection, path: path }.to_json
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      puts "Webhook repsonded with Status: #{res.code} #{res.message}"
      puts "When Traject is done, don't forget to process hourlies and flip the collection"
    end

    desc 'Clear Hourlies'
    task clear_hourlies: :environment do
      traject_webhook_url = ENV['TRAJECT_WEBHOOK_URL']
      uri = URI("http://#{traject_webhook_url}/rake")

      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { command: 'traject:clear_hourlies' }.to_json
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      puts "Webhook responded with Status: #{res.code} #{res.message}"
    end

    desc 'Run Hourlies'
    task :hourlies, [:collection] => [:environment] do |_task, args|
      traject_webhook_url = ENV['TRAJECT_WEBHOOK_URL']
      uri = URI("http://#{traject_webhook_url}/hourlies")
      collection = args['collection'] || solr_manager.last_incremented_collection

      puts "Asking Traject to run hourlies on #{collection}"
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = { collection: collection }.to_json
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      puts "Webhook responded with Status: #{res.code} #{res.message}"
    end

  end
end
