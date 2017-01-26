class Parliament < ActiveRecord::Base
	translates :name

	has_many :parliament_translations, :dependent => :destroy

  has_many :upload_files
  has_many :agendas

  accepts_nested_attributes_for :parliament_translations
  attr_accessible :name_old, :start_year, :end_year, :id, :parliament_translations_attributes

  def self.sorted_start_year
    with_translations(I18n.locale).order("parliaments.start_year desc, parliament_translations.name asc")
  end

  def to_hash
    {
      internal_id: self.id,
      start_year: self.start_year,
      end_year: self.end_year,
      name: self.name,
      name_formatted: self.name_formatted
    }
  end

  def name_formatted
    "#{start_year} - #{end_year} (#{name})"
  end


  #######################################
  #######################################
  ### api
  #######################################
  #######################################

  #######################################
  ### V2
  #######################################

  # get all parliaments on record
  def self.api_v2_parliaments
    sorted_start_year.map{|x| x.to_hash}
  end


end
