require "action_mailer/mandrill/version"
require 'active_support/concern'

module ActionMailer
  # Adds a new way to send mails via Mandrill (actually uses normal SMTP 
  # just sets specific SMTP headers)
  # 
  # @example Sending a mail via Mandrill with specific template
  #   
  #   def notification(user)
  #     @user = user
  #     
  #     mandrill_mail('user_invite', 
  #       to: 'max@example.com', 
  #       subject: 'test', 
  #       merge_objects: [user]
  #     )
  #   end
  # 
  module Mandrill
    extend ActiveSupport::Concern
    
    # Sends a mail with a specific mandrill template
    # See http://help.mandrill.com/entries/21688056-Using-SMTP-Headers-to-customize-your-messages
    # to learn more about each option.
    # 
    # @param [String] template_slug The slug that identifies the template to use
    # @param [Hash] options The options for the mail, such as sender, receiver, etc.
    # 
    # @option options [String|Array]    :to Recipient email
    # @option options [String]          :from Sender email (respects AM defaults)
    # @option options [String]          :subject The subject
    # @option options [String]          :link_tracking See X-MC-Track
    # @option options [Array]           :merge_objects Used to generate X-MC-MergeVars, 
    #   need to be Mandrill Serializable (!)
    # @option options [Hash]            :merge_tags Used to generate X-MC-MergeVars, 
    #   need to be Mandrill Serializable (!)
    # @option options [Array]           :tags Tag the email
    #
    # @raise [RuntimeError] if receivers are blank
    def mandrill_mail(template_slug, options = {})
      merge_tags = {}
    
      headers['X-MC-Template']      = template_slug
      headers['X-MC-Track']         = options.delete(:link_tracking) if options.has_key?(:link_tracking)
      headers['X-MC-Tags']          = options.delete(:tags).join(',') if options.has_key?(:tags)
    
      receiver_name                 = options.delete(:receiver_name)
    
      receivers = options.delete(:to)
      receivers = [receivers] unless receivers.is_a?(Array)
      raise RuntimeError.new("Please specify at least one receiver") if receivers.blank?
    
      if options.has_key?(:merge_objects)
        options.delete(:merge_objects).each do |o| 
          merge_tags = merge_tags.merge!(o.to_mandrill_merge_tags) 
        end
      end
    
      if options.has_key?(:merge_tags) 
        merge_tags = merge_tags.merge! options.delete(:merge_tags)
      end
    
      receivers.each do |receiver|
        headers['X-MC-MergeVars'] = JSON.generate(
          merge_tags.merge!('_rcpt' => receiver), 
          ascii_only: true
        )
      end
    
      options[:to] = receivers
      options[:to] = "#{receiver_name} <#{receivers.first}>" if receivers.length == 1 && receiver_name.present?
    
      mail(options) do |format|
        format.text { render text: '' }
      end
    end
    
  end
end
