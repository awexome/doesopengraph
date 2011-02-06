# AWEXOME LABS
# DoesOpenGraph
#
# GraphNode - An instance of an item on the open graph
#

module DoesOpenGraph
  class GraphNode < GraphResponse

    # Fetch an updated view of this node
    def reload
      up = api.node(self.id)
      @content = up.content
      self
    end
    
    # Introspect on the connections available to this node
    def introspect
      api.node(self.id, nil, :metadata=>1)
    end
    
    # Delete this node from the graph
    def delete
      api.delete(self.id)
    end
    
    # Like this node, if supported
    def like
      api.post(self.id, "likes")
    end
    
    # Unlike this node, if supported
    def unlike
      api.delete(self.id, "likes")
    end
    

  end # GraphNode    
end # DoesOpenGraph
      


