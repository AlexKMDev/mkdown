def show_help
  puts %q{
  Usage: ruby mkdown -t <access_token>
    -t <access_token> -- set up your access_token
    -s <keyword> -- process search by keyword
    -y -- said yes to all questions
    }
end

def safe_str(string)
  CGI.unescape_html(string).gsub(/\//, '\\')
end

def check_local_token
  File.exist?('token.lock') ? File.open('token.lock').read : false
end

def confirm
  print 'Music will be downloaded in new "music" directory in current directory. Ok? (y/n): '
  answer = STDIN.gets.chomp
  exit if answer.downcase != 'y'
end