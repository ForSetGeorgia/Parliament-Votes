class Delegate < ActiveRecord::Base
  has_paper_trail

  has_many :voting_results, :dependent => :destroy
  belongs_to :all_delegate
  belongs_to :group
  belongs_to :conference

  attr_accessible :xml_id, :conference_id, :group_id, :first_name, :title, :all_delegate_id
  attr_accessor :conf_start_date


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
