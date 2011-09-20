# AWEXOME
# DoesOpenGraph
#
# DoesOpenGraph - Module definition and loader

require 'hashie'

require "doesopengraph"
require "doesopengraph/graph_api"
require "doesopengraph/graph_request"
require "doesopengraph/graph_response"

module DoesOpenGraph
  
  def self.version
    Gem.loaded_specs["doesopengraph"].version.to_s
  end
  
end
