# AWEXOME LABS
# DoesOpenGraph
#
# GraphResponse - A very simple wrapper for data returned by the OpenGraph API
#

module DoesOpenGraph
  class GraphResponse

    attr_reader :content, :api

    # Build a Response object from request content and store the api
    def initialize(content, api=nil)
      @content = content.is_a?(Hash) ? content : Hash.new
      @api = api
    end
      
    # Use secret patching to provide accessors to connections within node
    def method_missing(m, *args, &block)
      content.include?(m.to_s) ? content[m.to_s] : nil
    end

  end # GraphResponse    
end # DoesOpenGraph
      

