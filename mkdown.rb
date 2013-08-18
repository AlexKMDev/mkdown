#!/usr/bin/ruby
# encoding: utf-8

require 'net/http'
require 'json'
require 'cgi'

def show_help
  puts 'Usage: ./mkdown.rb <access_token> or ruby mkdown.rb <access_token>'
end

def get_audio_list(token)
  puts 'downloading audio list...'

  uri = URI('https://api.vk.com/method/audio.get?access_token=' + token)
  response = Net::HTTP.get uri

  JSON.parse response
end

def safe_str(string)
  CGI.unescapeHTML(string).gsub(/\//, '\\')
end

def save_file(filename, file_uri)
  music_dir = Dir.pwd + '/music/'
  Dir.mkdir music_dir, 0755 unless Dir.exist? music_dir

  if File.file? music_dir + filename
    puts "#{filename} already exists."
  else
    puts "downloading #{filename}..."

    File.open music_dir + filename, 'wb' do |f|
      response = Net::HTTP.get file_uri
      f.write response
    end
  end
end

def prepare_songs(audio_list)
  queue_count = audio_list.count
  puts "#{queue_count} songs in queue."

  audio_list.each_index do |song|
    print "[#{ song + 1 }/#{ queue_count }] "

    song = audio_list[song]
    filename = safe_str "#{ song['artist'] } - #{ song['title'] }.mp3"
    file_uri = URI.parse song['url']

    save_file filename, file_uri
  end
end

if !ARGV.first || ARGV.first == '-h'
  show_help
else
  print 'Music will be downloaded in new "music" directory in current directory. Ok? (y/n): '
  answer = STDIN.gets.chomp
  exit if answer.downcase != 'y'

  audio_list = get_audio_list ARGV.first

  if audio_list['error'].nil?
    prepare_songs audio_list['response']
  else
    puts audio_list['error']['error_msg']
  end
end
