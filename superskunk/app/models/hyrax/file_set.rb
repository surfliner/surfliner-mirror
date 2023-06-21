module Hyrax
  class FileSet < Valkyrie::Resource
    ##
    # @return [Boolean] true
    def file_set?
      true
    end

    ##
    # @return [Boolean] true
    def work?
      false
    end
  end
end
