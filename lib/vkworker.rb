class VKWorker
  API_URI = 'https://api.vk.com/method/'
  METHODS = { search: 'audio.search', get: 'audio.get' }

  attr_reader :token, :audio_list
  attr_accessor :verbose

  def initialize(token)
    @token = "access_token=#{token}"
    @verbose = false
    @audio_list = {}
    save_token(token)
  end

  def download_my_songs
    get_audio_list
    prepare_songs
  end

  def search_songs(keyword)
    puts 'processing search...' if @verbose

    uri = URI(API_URI + METHODS[:search] + "?#{@token}&q=#{keyword}")
    response = JSON.parse(api_request(uri))

    error?(response)
    @audio_list = response['response']
  end

  protected

  def get_audio_list
    puts 'downloading audio list...' if @verbose

    uri = URI(API_URI + METHODS[:get] + '?' + @token)
    response = JSON.parse(api_request(uri))

    error?(response)
    @audio_list = response['response']
  end

  def save_token(token)
    File.open('.token', 'w').write(token)
  end

  def prepare_songs
    queue_count = @audio_list.count
    puts "#{queue_count} songs in queue."

    @audio_list.each_index do |song|
      print "[#{ song + 1 }/#{ queue_count }] "

      song = @audio_list[song]
      filename = safe_str "#{ song['artist'] } - #{ song['title'] }.mp3"
      file_uri = URI.parse song['url']

      save(filename, file_uri)
    end
  end

  def dir_path
    music_dir = Dir.pwd + '/music/'
    Dir.mkdir(music_dir, 0755) unless Dir.exist?(music_dir)
    music_dir
  end

  def get_fullpath(filename)
    dir_path + filename
  end

  def song_exist?(path)
    File.file?(path)
  end

  def error?(response)
    if response['error']
      puts response['error']['error_msg']
      exit
    end
  end

  def api_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)

    http.request(request).body
  end

  def download(uri)
    Net::HTTP.get(uri)
  end

  def save(filename, file_uri)
    path = get_fullpath(filename)

    if song_exist?(path)
      puts "#{filename} already exists." if @verbose
    else
      puts "downloading #{filename}..." if @verbose

      File.open(path, 'wb') do |f|
        f.write(download(file_uri))
      end
    end
  end
end
