#!/usr/bin/ruby
# encoding: utf-8

require 'net/http'
require 'json'
require 'cgi'
require './lib/helper'
require './lib/vkworker'


token = check_local_token
token = ARGV[ARGV.index('-t') + 1] if token.empty?

if (ARGV.empty? || ARGV.include?('-h')) && token.empty?
  show_help
else
  handler = VKWorker.new(token)

  case ARGV.first
    when '-s'
      result = handler.search_songs ARGV[1]
      result.shift
      result.each do |song|
        mm, ss = song['duration'].divmod(60)
        ss = "0#{ss}" if ss < 10
        puts "#{song['artist']} #{song['title']} - #{mm}:#{ss}"
      end
    else
      confirm unless ARGV.include? '-y'
      handler.download_my_songs
  end
end
