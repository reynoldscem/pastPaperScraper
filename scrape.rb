require 'nokogiri'
require 'open-uri'
require 'date'
require 'fileutils'

baseURL = 'http://studentnet.cs.manchester.ac.uk/assessment/exam_papers/index.php'
courseEntrySelector = 'div.indentdiv div.indentdiv'
courseTitleSelector = 'h2'
contentLinkSelector = 'ul li a'

# Just for the sake of variable name readability
courses = ARGV.map {|arg| arg.upcase }

# Years are hardcoded... Can't think of a better way considering
# past papers may be released at different times.
(2006..2014).each do |year|
  yearSelectionURLSuffix = "?view=&year=#{year}"
  thisURL = baseURL + yearSelectionURLSuffix
  page = Nokogiri::HTML(open(thisURL))

  # Hash to hold all course names to array of links
  courseToLinks = Hash.new(Array.new)

  # For each course
  page.css(courseEntrySelector).each do |courseEntry|
    # Get name and trim to just module code
    name = courseEntry.css(courseTitleSelector).text.split.first

    # Select set of links entities and map to plain URLs
    courseToLinks[name] = courseEntry.css(contentLinkSelector).map do |link|
      link.get_attribute('href')
    end
  end

  # Remove all courses codes not given as args
  desiredCoursesToLinks = courseToLinks.select{|title, links| courses.include? title }

  # For each course
  desiredCoursesToLinks.each do |courseName, links|
    # Get directory handle for this course and years
    dirForThisYear = "#{courseName}/#{year}-#{year+1}"

    # Make a relevant directory for this year if it does not exist
    FileUtils.mkdir_p dirForThisYear

    links.each do |link|
      # Get handle to save this links contents by
      filename = "#{dirForThisYear}/#{File.basename(link)}"
      # Download write it, if we have not previously downloaded it
      # Gsub is to treat space characters properly
      File.write(filename, open(link.gsub(" ","%20")).read) unless File.exists? filename
    end
  end
end
