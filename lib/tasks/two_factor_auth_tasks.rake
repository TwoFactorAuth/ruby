namespace :two_factor_auth do
  desc "View the TwoFactorAuth readme"
  task :readme do
    begin
      pager = ENV['PAGER']
      pager = 'less' if pager.blank?
      readme = File.expand_path("../../../README.md", __FILE__)
      exec "#{pager} #{readme}"
    rescue Errno::ENOENT
      puts "Sorry, couldn't automatically print it... here's the readme:", readme
    end
  end
end
