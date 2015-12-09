require 'nokogiri'
require 'open-uri'
require 'pry'
require 'date'
require 'fileutils'

baseURL = 'http://studentnet.cs.manchester.ac.uk/assessment/exam_papers/index.php'

fullName = false

course = ["COMP11120", "COMP25111"]
(2006..2014).each do |year|
  suffix = "?view=&year=#{year}"

  page = Nokogiri::HTML(open(baseURL))

  courseToLinks = Hash.new(Array.new)

  page.css('div.indentdiv div.indentdiv').each do |courseEntry|
    name = courseEntry.css('h2').text
    name = name.split.first unless fullName
    courseToLinks[name] = courseEntry.css('ul li a').map do |link|
      link.get_attribute('href')
    end
  end

  courseToLinks = courseToLinks.select{|k,v| course.include?(k)}

  courseToLinks.each do |courseName, links|
    FileUtils.mkdir_p "#{courseName}/#{year}-#{year+1}"
    links.each do |link|
      File.write("#{courseName}/#{year}-#{year+1}/#{File.basename(link)}", open(link).read)
    end
  end
end

binding.pry
