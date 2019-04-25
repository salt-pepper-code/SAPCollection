Pod::Spec.new do |s|
  s.name = 'SAPCollection'
  s.version = '1.0'
  s.license = 'MIT'
  s.summary = 'SAPCollection Swift 4.2'
  s.description  = <<-DESC 
                  TO DO 
                   DESC
  s.homepage = 'https://github.com/kmalkic/SAPCollection'
  s.authors = { 'Salt and Pepper Code' => 'k_malkic@yahoo.fr' }
  s.source = { :git => 'https://github.com/kmalkic/SAPCollection.git', :tag => s.version.to_s }
  s.platform = :ios, '11.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
  s.source_files = 'SAPCollection/Collection.Namespace.swift', 'SAPCollection/Extensions/*.swift', 'SAPCollection/Collection/Component/Switch/*.swift', 'SAPCollection/Collection/Component/PageControl/*.swift'
  s.requires_arc = true

  s.dependency 'MKTween'
end