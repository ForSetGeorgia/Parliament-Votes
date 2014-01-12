class NotificationTrigger < ActiveRecord::Base
  attr_accessible :notification_type, :identifier, :processed

  scope :not_processed, where(:processed => false)
  
  def self.process_all_types
    process_new_files
    process_changed_votes
    process_law_is_public
    process_new_delegates
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

          NotificationMailer.change_vote(message).deliver if message.message2.present?
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
      I18n.available_locales.each do |locale|
        message = Message.new
		    message.bcc = Notification.new_file(locale)
        if message.bcc.length > 0
	        message.locale = locale
	        message.subject = I18n.t("mailer.notification.new_file.subject", :locale => locale)
	        message.message = I18n.t("mailer.notification.new_file.message", :locale => locale)
          message.message2 = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            conf = Conference.not_deleted.find_by_upload_file_id(id)
            if conf.present?
              message.message2 << [I18n.l(conf.start_date, :format => :no_zone, :locale => locale), conf.upload_file_id]
		        end
	        end

          NotificationMailer.new_file(message).deliver if message.message2.present?
        end
      end
    
      # mark these as processed
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

    end
  end

  #################
  ## law is public
  #################
  def self.add_law_is_public(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:law_is_public], :identifier => id)
  end

  def self.process_law_is_public
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:law_is_public]).not_processed

    if triggers.present?
      I18n.available_locales.each do |locale|
        message = Message.new
	      message.bcc = Notification.law_is_public(locale)
        if message.bcc.length > 0
	        message.locale = locale
	        message.subject = I18n.t("mailer.notification.law_is_public.subject", :locale => locale)
	        message.message = I18n.t("mailer.notification.law_is_public.message", :locale => locale)
          message.message2 = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            agenda = Agenda.not_deleted.public.find_by_id(id)
            if agenda.present?
              message.message2 << [agenda.official_law_title, agenda.public_url_id]
		        end
	        end

          NotificationMailer.law_is_public(message).deliver if message.message2.present?
        end
      end

      # mark these as processed
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

    end
  end


  #################
  ## new delegate
  #################
  def self.add_new_delegate(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:new_delegate], :identifier => id)
  end

  def self.process_new_delegates
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:new_delegate]).not_processed

    if triggers.present?
      I18n.available_locales.each do |locale|
        puts "@@@@@@@@ - locale = #{locale}"
        message = Message.new
	      message.bcc = Notification.new_delegate(locale)
        puts "@@@@@@@@ - message bcc = #{message.bcc}"
        if message.bcc.length > 0
	        message.locale = locale
	        message.subject = I18n.t("mailer.notification.new_delegate.subject", :locale => locale)
	        message.message = I18n.t("mailer.notification.new_delegate.message", :locale => locale)
          message.message2 = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            delegate = AllDelegate.find_by_id(id)
            if delegate.present?
              message.message2 << [delegate.first_name, delegate.id]
		        end
	        end

          puts "@@@@@@@@ - sending delegate notification = #{message.message2}"
          NotificationMailer.new_delegate(message).deliver if message.message2.present?
        end
      end

      # mark these as processed
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

    end
  end



end
