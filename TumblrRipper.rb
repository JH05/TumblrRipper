require 'mechanize'

# Gets username parameter.
ARGV.each do|username|

# Creates directory
FileUtils.mkdir_p(username)

# Settings
start = 0
number = 50

loop do
  url = "http://#{username}.tumblr.com/api/read?type=photo&num=#{number}&start=#{start}"
  page = Mechanize.new.get(url)
  doc = Nokogiri::XML.parse(page.body)

  images = (doc/'post photo-url').select{|x| x if x['max-width'].to_i == 1280 }
  imageurl = images.map {|x| x.content }

  imageurl.each_slice(8).each do |group|
    threads = []
    group.each do |url|
      threads << Thread.new {
        puts "Saving photo #{url}"
        begin
          file = Mechanize.new.get(url)
          filename = File.basename(file.uri.to_s.split('?')[0])
          file.save_as("#{username}/#{filename}")
        end
      }
    end
    threads.each{|t| t.join }
  end

  puts "#{images.count} Images Found."
  if images.count < number
    puts "Finished."
    break
  else
    start += number
  end

end

end
