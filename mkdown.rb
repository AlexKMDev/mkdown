#!/usr/bin/ruby
# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/lib')

require 'net/http'
require 'json'
require 'cgi'
require 'helper'
require 'vkworker'

token = get_token

if (ARGV.empty? || param?('-h')) && !token
  show_help
else
  handler = VKWorker.new(token)

  handler.verbose = true if param?('-v')

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
    confirm unless param?('-y')
    handler.download_my_songs
  end
end
