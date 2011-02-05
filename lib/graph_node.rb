# AWEXOME LABS
# DoOpenGraph
#
# GraphNode - An instance of an item on the open graph
#

module DoOpenGraph
  class GraphNode < GraphResponse

    # Fetch an updated view of this node
    def reload
      up = api.node(self.id)
      @content = up.content
      self
    end

  end # GraphNode    
end # DoOpenGraph
      


