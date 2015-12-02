require 'nokogiri'
require 'open-uri'
require 'pry'

scrapeURL = 'http://studentnet.cs.manchester.ac.uk/assessment/exam_papers/index.php'

page = Nokogiri::HTML(open(scrapeURL))

courseToLinks = Hash.new []

page.css('div.indentdiv div.indentdiv').each do |course|
  name = course.css('h2').text
  course.css('ul li a').each do |link|
    courseToLinks[name] << link.get_attribute('href')
  end
end

