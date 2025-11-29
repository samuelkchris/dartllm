Pod::Spec.new do |s|
  s.name             = 'dartllm'
  s.version          = '0.1.0'
  s.summary          = 'DartLLM native library for iOS'
  s.description      = <<-DESC
Local LLM inference library for iOS using llama.cpp.
                       DESC
  s.homepage         = 'https://github.com/example/dartllm'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'DartLLM' => 'dartllm@example.com' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '14.0'

  s.vendored_frameworks = 'Frameworks/llamacpp.xcframework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  s.frameworks = 'Metal', 'MetalKit', 'Accelerate'
end
