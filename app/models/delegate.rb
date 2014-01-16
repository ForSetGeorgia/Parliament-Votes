class Delegate < ActiveRecord::Base
  has_paper_trail

  has_many :voting_results, :dependent => :destroy
  belongs_to :all_delegate
  belongs_to :group
  belongs_to :conference

  attr_accessible :xml_id, :conference_id, :group_id, :first_name, :title, :all_delegate_id
  attr_accessor :conf_start_date

  # if this is not Georgian, return the english equivalent of the first name
  def first_name
    if I18n.locale == :ka
      self.read_attribute(:first_name)
    else
      require 'utf8_converter'
      Utf8Converter.convert_ka_to_en(self.read_attribute(:first_name)).gsub(/[^A-Za-z ]/,'').titlecase
    end
  end
  

  def self.add_missing_all_delegate_id(parliament_id)
    all_delegates = AllDelegate.where(:parliament_id => parliament_id)

    delegates = Delegate.joins(:conference => :upload_file).where('upload_files.parliament_id = ? and delegates.all_delegate_id is null', parliament_id).readonly(false)
    delegates.find_each do |delegate|
      all_del_index = all_delegates.index{|x| x.xml_id.to_s == delegate.xml_id.to_s && x.first_name == delegate.first_name}
      if all_del_index.present?
        delegate.all_delegate_id = all_delegates[all_del_index].id
        delegate.save
      end
    end
  end
end
