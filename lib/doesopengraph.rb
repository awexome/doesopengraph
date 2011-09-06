# AWEXOME
# DoesOpenGraph
#
# DoesOpenGraph - Module definition and loader

require "doesopengraph"
require "doesopengraph/graph_api"
require "doesopengraph/graph_response"
require "doesopengraph/graph_node"

module DoesOpenGraph
  
  def self.version
    Gem.loaded_specs["doesopengraph"].version.to_s
  end
  
end
