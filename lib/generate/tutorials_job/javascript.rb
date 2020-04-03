require 'git'

module Generate
  module TutorialsJob
    class Javascript < Base
      def initialize(options = {})
        options[:src_tutorials_path] = 'tutorials/devportal-tutorials-js'
        options[:dest_tutorials_path] ||= '_tutorials-javascript'
        
        super
      end
    end
  end
end
