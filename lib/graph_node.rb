# AWEXOME LABS
# DoOpenGraph
#
# GraphNode - An instance of an item on the open graph
#

module DoOpenGraph
  class GraphNode

    attr_reader :content, :api

    # Build a Node object from request content and store the api
    def initialize(content, api=nil)
      @content = content.is_a?(Hash) ? content : Hash.new
      @api = api
    end
    
    # Fetch an updated view of this node
    def reload
      up = api.node(self.id)
      @content = up.content
      self
    end
  
    # Use secret patching to provide accessors to connections within node
    def method_missing(m, *args, &block)
      content.include?(m.to_s) ? content[m.to_s] : nil
    end

  end # GraphNode    
end # DoOpenGraph
      


