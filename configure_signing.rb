require 'xcodeproj'

project_path = '/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven.xcodeproj'
project = Xcodeproj::Project.open(project_path)

if project.root_object.attributes['TargetAttributes'].nil?
  project.root_object.attributes['TargetAttributes'] = {}
end

project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['DEVELOPMENT_TEAM'] = '3YH5RQ572Q'
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    
    config.build_settings.delete('CODE_SIGN_IDENTITY')
    config.build_settings.delete('CODE_SIGN_IDENTITY[sdk=iphoneos*]')
    config.build_settings.delete('PROVISIONING_PROFILE_SPECIFIER')
  end
  
  project.root_object.attributes['TargetAttributes'][target.uuid] = {
    'ProvisioningStyle' => 'Automatic',
    'DevelopmentTeam' => '3YH5RQ572Q'
  }
end

project.save
puts "Successfully configured automatic code signing with Team ID 3YH5RQ572Q!"
