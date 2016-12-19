require "json"
require "selenium-webdriver"
require "rspec"
require 'tmpdir'
require 'pry'
require 'yaml'
require 'capybara/poltergeist'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

require_relative 'drive.rb'


include RSpec::Expectations

class Driver
  Capybara.default_driver = :webkit
  Capybara.javascript_driver = :webkit
  Capybara.default_max_wait_time = 60
  include Capybara::DSL
end

class PayslipReport

  KINNOSUKE_URL = "https://www.4628.jp/"


  def payslip(folderID)
    config = YAML.load_file('./secret/config.yml')
    kinnosuke = config["kinnosuke"]
    @company_id = kinnosuke["company_id"]
    @login_id = kinnosuke["login_id"]
    @password = kinnosuke["password"]



    @driver = Driver.new

    #ログイン処理
    @driver.visit KINNOSUKE_URL
    @driver.fill_in "y_companycd", with: @company_id
    @driver.fill_in "y_logincd", with: @login_id
    @driver.fill_in "password", with: @password
    @driver.click_button 'id_passlogin'



    sleep 5
    @driver.visit KINNOSUKE_URL + "/?module=yonosuke/payslip&action=yonosuke/payslip"
    @driver.find(:xpath,'//*[@id="main_table"]/tbody/tr/td/table[2]/tbody/tr/td/div[2]/table/tbody/tr[2]/td[7]/form' ,match: :first).click
    @driver.click_button("PDF出力")
    sleep 20
    date = Date.today
    filepath = "/tmp/" + date.to_s + "-salary.pdf"
    file = File.open(filepath,"w") do |file|
      file.print @driver.body
    end



    gdUtil = GoogleDriveUtilYourSelf.new
    content_type = "application/pdf"
    file_id = gdUtil.uploadFileToGoogleDrive(filepath,folderID,content_type)
    puts "file upload at " + file_id

  end

end
