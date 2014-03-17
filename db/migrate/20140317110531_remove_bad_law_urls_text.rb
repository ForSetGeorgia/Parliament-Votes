class RemoveBadLawUrlsText < ActiveRecord::Migration
  def up
    bad_url = "http://www.parliament.ge/index.php?option=com_content&view=article&id=2&Itemid=34&lang=ge"

    Agenda.transaction do
      # get bad blob text
      sql = "select law_url_text from agendas where law_url = '#{bad_url}' limit 1"
      x = Agenda.find_by_sql(sql)
      if x.present?

        # reset all law_url_text that is bad
        sql = "update agendas set law_url_text = null where law_url_text = '#{x.first.law_url_text}'"
        ActiveRecord::Base.connection.execute(sql)
      
        # reset all bad urls
        sql = "update agendas set law_url = null where law_url = '#{bad_url}'"
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end

  def down
    # do nothing
  end
end
