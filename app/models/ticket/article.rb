# Copyright (C) 2012-2013 Zammad Foundation, http://zammad-foundation.org/

class Ticket::Article < ApplicationModel
  require 'ticket/article/assets'
  include Ticket::Article::Assets
  require 'ticket/article/history_log'
  include Ticket::Article::HistoryLog
  require 'ticket/article/activity_stream_log'
  include Ticket::Article::ActivityStreamLog

  belongs_to    :ticket
  belongs_to    :ticket_article_type,   :class_name => 'Ticket::Article::Type'
  belongs_to    :ticket_article_sender, :class_name => 'Ticket::Article::Sender'
  belongs_to    :created_by,            :class_name => 'User'
  after_create  :attachment_check
  after_create  :notify_clients_after_create
  after_update  :notify_clients_after_update
  after_destroy :notify_clients_after_destroy

  activity_stream_support :ignore_attributes => {
    :ticket_article_type_id   => true,
    :ticket_article_sender_id => true,
  }

  history_support :ignore_attributes => {
    :ticket_article_type_id   => true,
    :ticket_article_sender_id => true,
  }

  attr_accessor :attachments

  private

  def attachment_check

    # do nothing if no attachment exists
    return 1 if self.attachments == nil

    # store attachments
    article_store = []
    self.attachments.each do |attachment|
      article_store.push Store.add(
        :object        => 'Ticket::Article',
        :o_id          => self.id,
        :data          => attachment.store_file.data,
        :filename      => attachment.filename,
        :preferences   => attachment.preferences,
        :created_by_id => self.created_by_id,
      )
    end
    self.attachments = article_store
  end

  class Flag < ApplicationModel
  end

  class Sender < ApplicationModel
    validates   :name, :presence => true
  end

  class Type < ApplicationModel
    validates   :name, :presence => true
  end
end
