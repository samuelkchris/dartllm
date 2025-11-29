Pod::Spec.new do |s|
  s.name             = 'dartllm'
  s.version          = '0.1.0'
  s.summary          = 'DartLLM native library for macOS'
  s.description      = <<-DESC
Local LLM inference library for macOS using llama.cpp.
                       DESC
  s.homepage         = 'https://github.com/example/dartllm'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'DartLLM' => 'dartllm@example.com' }
  s.source           = { :path => '.' }
  s.platform         = :osx, '11.0'

  s.vendored_frameworks = 'Frameworks/llamacpp.framework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  s.frameworks = 'Metal', 'MetalKit', 'Accelerate'
end
