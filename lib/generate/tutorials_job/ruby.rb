require 'git'

module Generate
  module TutorialsJob
    class Ruby < Base
      def initialize(options = {})
        options[:src_tutorials_path] = 'tutorials/devportal-tutorials-rb'
        options[:dest_tutorials_path] ||= '_tutorials-ruby'
        
        super
      end
    end
  end
end
