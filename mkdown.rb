#!/usr/bin/ruby
# encoding: utf-8
#
# please get new token by visiting link below
# https://oauth.vk.com/authorize?client_id=3718612&scope=audio,offline&redirect_uri=http://oauth.vk.com/blank.html&display=wap&response_type=token
require 'net/http'
require 'json'
require 'cgi'

def show_help
	puts <<-eos
	-h - show this message
	<token> - download all your songs, access_token required
	eos
end

def get_audio_list(token)
	puts 'downloading audio list...'

	uri = URI('https://api.vk.com/method/audio.get?access_token=' + token)
	response = Net::HTTP.get(uri)

	JSON.parse response
end

def save_songs(audio_list)
	queue_count = audio_list.count.to_s
	puts queue_count + ' songs in queue.'

	music_dir = Dir.pwd + '/music/'

	unless Dir.exist? music_dir
		Dir.mkdir music_dir, 0755
	end

	audio_list.each_index do |song|
		print '[' + (song + 1).to_s + '/' + queue_count + '] '

		song = audio_list[song]
		filename = CGI.unescapeHTML((song['artist'] + ' - ' + song['title'] + '.mp3').gsub(/\/|\\/, '\\'))
		file_uri = URI.parse song['url']

		if File.file?(music_dir + filename)
			puts filename + ' already exists.'
		else
			puts 'downloading ' + filename + '...'
			File.open(music_dir + filename, 'wb') do |f|
				Net::HTTP.start(file_uri.host) do |http|
					response = http.get(file_uri)
					f.write(response.body)
				end
			end
		end
	end
end

if ARGV.empty? or ARGV[0] == '-h'
	show_help
elsif not ARGV[0].empty?
	audio_list = get_audio_list(ARGV[0].to_s)

	if audio_list['error'].nil?
		save_songs(audio_list['response'])
	else
		puts audio_list['error']['error_msg']
	end
end
