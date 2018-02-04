Pod::Spec.new do |s|
  s.name = 'Firelite'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Firebase entities integration for Swift'
  s.homepage = 'https://github.com/FireliteTeam/Firelite'
  s.authors = { 'ESGI' => 'info@esgi.org' }
  s.source = { :git => 'https://github.com/FireliteTeam/Firelite.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Firelite/*.swift'
end
