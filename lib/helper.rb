def show_help
  puts %q{
  Usage: ruby mkdown -t <access_token>
    -t <access_token> -- set up your access_token
    -s <keyword> -- process search by keyword
    -y -- said yes to all questions
    -v -- verbose output
    }
end

def safe_str(string)
  CGI.unescape_html(string).gsub(/\//, '\\')
end

def check_local_token
  token = false
  if File.exist?('.token')
    puts 'token loaded from file.' if param?('-v')
    token = File.open('.token').read
    token = false if token.chomp.empty?
  end

  token
end

def get_token
  token = get_param('-t') || check_local_token

  puts 'Error: access token required.' unless token
  token
end

def get_param(key)
  ARGV[ARGV.index(key) + 1] if param?(key)
end

def confirm
  print 'Music will be downloaded in new "music" directory. Ok? (y/n): '
  answer = STDIN.gets.chomp
  exit if answer.downcase != 'y'
end

def param?(key)
  ARGV.include?(key)
end
