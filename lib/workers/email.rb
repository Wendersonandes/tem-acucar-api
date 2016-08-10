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
      full_message = "Olá, #{user.first_name}!\n\n#{message}\n\n"
      if user.authentications_dataset.count > 0
        app_text = "Para saber mais ou responder, acesse o aplicativo do Tem Açúcar."
        app_html = app_text
      else
        app_text = "Para saber mais ou responder, baixe o aplicativo do Tem Açúcar em http://temacucar.com"
        app_html = "Para saber mais ou responder, baixe o aplicativo do Tem Açúcar.<br/><br/><a href='https://play.google.com/store/apps/details?id=com.temacucar'><img src='http://temacucar.com/assets/google-play-14e76c459d0263ff4ac041804589fd51abc51b0d3705f298d0fd551fd166b385.png' title='Google Play' alt='Google Play' width='200' height='60' style='width:200px;height:60px;'/></a>&nbsp;&nbsp;&nbsp;<a href='https://itunes.apple.com/us/app/tem-acucar/id1136121900?ls=1&mt=8'><img src='http://temacucar.com/assets/app-store-a3b52958ab3ca313719a7763f2aa5f6238c7a2375bd693f31e5b0d01bc29d2d0.png' title='App Store' alt='App Store' width='200' height='60' style='width:200px;height:60px;'/></a>"
      end
      mailer.mail({
        from: 'ola@temacucar.com',
        from_name: 'Tem Açúcar?',
        html: "#{full_message.gsub("\n", "<br/>")}#{app_html}",
        text: "#{full_message}#{app_text}",
        subject: subject
      })
    end
  end
end
