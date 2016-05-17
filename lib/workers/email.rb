module Workers
  class Email < Base
    def perform(user_id, subject, message)
      user = User[user_id]
      return unless user
      email = "#{user.full_name} <#{user.email}>"
      recipients = [SendGrid::Recipient.new(email)]
      template = SendGrid::Template.new(Config.sendgrid_template_id)
      client = SendGrid::Client.new(api_key: Config.sendgrid_api_key)
      mailer = SendGrid::TemplateMailer.new(client, template, recipients)
      full_message = "Olá, #{user.first_name}!\n\n#{message}\n\nPara saber mais ou responder, acesse o aplicativo do Tem Açúcar."
      mailer.mail({
        from: 'ola@temacucar.com',
        from_name: 'Tem Açúcar?',
        html: full_message.gsub("\n", "<br/>"),
        text: full_message,
        subject: subject
      })
    end
  end
end
