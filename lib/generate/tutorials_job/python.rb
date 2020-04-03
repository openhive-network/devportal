require 'git'

module Generate
  module TutorialsJob
    class Python < Base
      def initialize(options = {})
        options[:src_tutorials_path] = 'tutorials/devportal-tutorials-py'
        options[:dest_tutorials_path] ||= '_tutorials-python'
        
        super
      end
    end
  end
end
