require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Drive API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'secret/client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "payslip_repot.yaml")
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

class GoogleDriveUtilYourSelf

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end


  def uploadFileToGoogleDrive(filepath,folder_id,content_type)

    # Initialize the API
    service = Google::Apis::DriveV3::DriveService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
=begin
    # List the 10 most recently modified files.
    response = service.list_files(page_size: 10,
                                  fields: 'nextPageToken, files(id, name)')
    puts 'Files:'
    puts 'No files found' if response.files.empty?
    response.files.each do |file|
      puts "#{file.name} (#{file.id})"
    end
=end

    #folder_id = '0B5BFEHfz8NvxU3FSSjZ4aUVvM2c'

    filename = File.basename(filepath)
    file_metadata = {
      name: filename,
      parents: [folder_id]
    }
    file = service.create_file(file_metadata,
                                     fields: 'id',
                                     upload_source: filepath,
                                     content_type: content_type)
    #puts "File Id: #{file.id}"

    return file.id

  end


end
