class VKWorker
  attr_accessor :token, :verbose, :yes, :audio_list

  def initialize(token)
    @token = token
    File.open('token.lock', 'w').write token
  end

  def verbose
    @verbose = true
  end

  def download_my_songs
    get_audio_list
    prepare_songs
  end

  def search_songs(keyword)
    puts 'processing search...' if @verbose

    uri = URI("https://api.vk.com/method/audio.search?access_token=#{@token}&q=#{keyword}&auto_complete=1")
    response = JSON.parse Net::HTTP.get uri

    fail response['error']['error_msg'] if response['error']
    @audio_list = response['response']
  end

  protected

  def get_audio_list
    puts 'downloading audio list...' if @verbose

    uri = URI('https://api.vk.com/method/audio.get?access_token=' + @token)
    response = JSON.parse Net::HTTP.get uri

    fail response['error']['error_msg'] if response['error']
    @audio_list = response['response']
  end

  def prepare_songs
    queue_count = @audio_list.count
    puts "#{queue_count} songs in queue."

    @audio_list.each_index do |song|
      print "[#{ song + 1 }/#{ queue_count }] "

      song = @audio_list[song]
      filename = safe_str "#{ song['artist'] } - #{ song['title'] }.mp3"
      file_uri = URI.parse song['url']

      save_file filename, file_uri

    end
  end

  def save_file(filename, file_uri)
    music_dir = Dir.pwd + '/music/'
    Dir.mkdir music_dir, 0755 unless Dir.exist? music_dir

    if File.file? music_dir + filename
      puts "#{filename} already exists."
    else
      puts "downloading #{filename}..." if @verbose

      File.open music_dir + filename, 'wb' do |f|
        response = Net::HTTP.get file_uri
        f.write response
      end
    end
  end

end
