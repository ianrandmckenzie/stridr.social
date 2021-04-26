class CreateInfographicWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(current_user)
    current_user = User.find(current_user)

    html  = 'https://stridr.social/user/' + current_user.id.to_s + '.png'
    kit   = IMGKit.new html, width: 550, height: 850
    img   = kit.to_img(:png)
    file  = Tempfile.new(["template_#{current_user.id}", 'png'], 'tmp',
                         :encoding => 'ascii-8bit')
    file.write(img)
    file.flush
    current_user.infographic = file
    current_user.save
    file.unlink
  end
end
