class NotificationTrigger < ActiveRecord::Base
  attr_accessible :notification_type, :identifier, :processed

  scope :not_processed, where(:processed => false)
  
  def self.process_all_types
    process_new_files
    process_changed_votes
  end

  #################
  ## change vote
  #################
  def self.add_change_vote(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:change_vote], :identifier => id)
  end

  def self.process_changed_votes
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:change_vote]).not_processed

    if triggers.present?
      I18n.available_locales.each do |locale|
        message = Message.new
	      message.bcc = Notification.change_vote(locale)
        if message.bcc.length > 0
	        message.locale = locale
	        message.subject = I18n.t("mailer.notification.change_vote.subject", :locale => locale)
	        message.message = I18n.t("mailer.notification.change_vote.message", :locale => locale)
          message.message2 = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            agenda = Agenda.not_deleted.find_by_id(id)
            if agenda.present?
              message.message2 << ["#{agenda.official_law_title.present? ? agenda.official_law_title : agenda.name} (#{agenda.session_number})", agenda.id]
		        end
	        end

          NotificationMailer.change_vote(message).deliver
        end
      end

      # mark these as processed
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

    end
  end

  #################
  ## new file  
  #################
  def self.add_new_file(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:new_file], :identifier => id)
  end

  def self.process_new_files
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:new_file]).not_processed

    if triggers.present?
      triggers.map{|x| x.identifier}.uniq.each do |id|
        conf = Conference.not_deleted.find_by_upload_file_id(id)
        if conf.present?
		      message = Message.new
		      I18n.available_locales.each do |locale|
				    message.bcc = Notification.new_file(locale)
			      if message.bcc.length > 0
				      message.locale = locale
				      message.subject = I18n.t("mailer.notification.new_file.subject", :locale => locale)
				      message.message = I18n.t("mailer.notification.new_file.message", :date => I18n.l(conf.start_date, :format => :no_zone), :locale => locale)
				      message.url_id = conf.upload_file_id
				      NotificationMailer.new_file(message).deliver
			      end
		      end
        end
      end

      # mark these as processed
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

    end
  end


end
