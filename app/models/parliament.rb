class Parliament < ActiveRecord::Base
	translates :name

	has_many :parliament_translations, :dependent => :destroy

  has_many :upload_files
  has_many :agendas

  accepts_nested_attributes_for :parliament_translations
  attr_accessible :name_old, :start_year, :end_year, :id, :parliament_translations_attributes

  def self.sorted_name
    with_translations(I18n.locale).order("parliaments.start_year desc, parliament_translations.name asc")
  end
end
