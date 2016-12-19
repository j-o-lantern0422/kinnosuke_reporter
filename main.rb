$LOAD_PATH.push('libs')

require 'payslip_report'
require 'yaml'

config = YAML.load_file('./secret/config.yml')
folderID = config["google_drive"]["folderid"]

reporter = PayslipReport.new
reporter.payslip(folderID)
