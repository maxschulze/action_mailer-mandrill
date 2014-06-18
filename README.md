# ActionMailer::Mandrill

Use this gem to provide a nice `mandrill_mail` method to all your mailers.
It allows you to send mails via Mandrill SMTP using Mandrill Templates (only).
Using the mandrill_mail method you can easily set different Mandrill SMTP headers as well.

## Installation

Add this line to your application's Gemfile:

    gem 'action_mailer-mandrill'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install action_mailer-mandrill

## Usage

In your Mailer include the Mandrill Mailer:

    class UserMailer
      include ActionMailer::Mandrill
    end

Now you can use the mandrill mail method in your mail methods:

    def invitation_instructions(record)
      mandrill_mail 'user-friend-request', # mandrill template slug
        merge_objects:    [record.invited_by], # objects which attributes will 
                                               # converted to merge tags
        tags:             %w{ invite user },   # tag the email
        to:               record.email,        # ...
        receiver_name:    record.name,         # If a receiver name is given the email will be 
                                               # sent to "receiver_name <email>", only works if to 
                                               # is not an array
        from:             'noreply@example.com',
        subject:          subject,
        merge_tags:       { 
          receiver_name: record.name,
          link: accept_invitation_url(record, :invitation_token => @token),
          home_url: root_url
        } # add additional merge tags, e.g. receiver_name = *|RECEIVER_NAME|*
    end

See the documentation or inline comment in the code to see all available options.

**Also please use the [Mandrill::Serializer](https://github.com/maxschulze/mandrill-serializer) for `merge_objects`!**

## Contributing

1. Fork it ( https://github.com/maxschulze/action_mailer-mandrill/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
