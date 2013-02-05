class UploadFile < ActiveRecord::Base
  
  has_one :conference, :dependent => :destroy
  accepts_nested_attributes_for :conference

	attr_accessible :xml, :xml_file_name, :xml_content_type, :xml_file_size, :xml_updated_at, :conference_attributes

  validates :xml_file_name, :presence => true

	has_attached_file :xml, :url => "/system/upload_files/:id/:filename"
  


  def process_file
    file = File.open("#{Rails.root}/public#{self.xml.url(:original,false)}")

    doc = Nokogiri::XML(file)

    # conference
    conf = doc.at_css('Conference')
    puts "------------ conf date = #{conf.at_css('StartDate').text}"
    puts "------------ conf name = #{conf.at_css('name').text}"
    puts "------------ conf label = #{conf.at_css('conferenceLabel').text}"

    # groups
    doc.css('Group').each do |group|
      puts ""
      puts "------------ group id = #{group.at_css('id').text}"
      puts "------------ group text = #{group.at_css('Text').text}"
      puts "------------ group shortname = #{group.at_css('ShortName').text}"
    end

    # delegates
    doc.css('Delegate').each do |delegate|
      puts ""
      puts "------------ delegate id = #{delegate.at_css('id').text}"
      puts "------------ delegate group id = #{delegate.at_css('Group_id').text}" if delegate.at_css('Group_id')
      puts "------------ delegate firstname = #{delegate.at_css('firstname').text}"  if delegate.at_css('firstname')
      puts "------------ delegate title = #{delegate.at_css('title').text}" if delegate.at_css('title')
    end

    # agendas
    doc.css('Agenda').each do |agenda|
      puts ""
      puts "------------ agenda id = #{agenda.at_css('id').text}"
      puts "------------ agenda sort order = #{agenda.at_css('SortOrder').text}" if agenda.at_css('SortOrder')
      puts "------------ agenda level = #{agenda.at_css('Level').text}"  if agenda.at_css('Level')
      puts "------------ agenda name = #{agenda.at_css('Name').text}" if agenda.at_css('Name')
      puts "------------ agenda desc = #{agenda.at_css('Description').text}" if agenda.at_css('Description')
    end

    file.close
  end
end
