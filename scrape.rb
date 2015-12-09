require 'nokogiri'
require 'open-uri'
require 'pry'
require 'date'
require 'fileutils'

baseURL = 'http://studentnet.cs.manchester.ac.uk/assessment/exam_papers/index.php'

# Just for the sake of variable name readability
courses = ARGV

# Years are hardcoded... Can't think of a better way considering
# past papers may be released at different times.
(2006..2014).each do |year|
  suffix = "?view=&year=#{year}"
  thisURL = baseURL + suffix
  page = Nokogiri::HTML(open(thisURL))

  courseToLinks = Hash.new(Array.new)

  page.css('div.indentdiv div.indentdiv').each do |courseEntry|
    name = courseEntry.css('h2').text.split.first
    courseToLinks[name] = courseEntry.css('ul li a').map do |link|
      link.get_attribute('href')
    end
  end

  courseToLinks = courseToLinks.select{|title, links| courses.include? title }

  courseToLinks.each do |courseName, links|
    FileUtils.mkdir_p "#{courseName}/#{year}-#{year+1}"
    links.each do |link|
      filename = "#{courseName}/#{year}-#{year+1}/#{File.basename(link)}"
      File.write(filename, open(link.gsub(" ","%20")).read) unless File.exists? filename
    end
  end
end
