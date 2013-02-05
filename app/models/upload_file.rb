class UploadFile < ActiveRecord::Base
  
  has_one :conference, :dependent => :destroy
  accepts_nested_attributes_for :conferences

	attr_accessible :xml, :xml_file_name, :xml_content_type, :xml_file_size, :xml_updated_at, :conferences_attributes

  validates :xml_file_name, :presence => true

	has_attached_file :xml, :url => "/system/upload_files/:id/:filename"
  

end
