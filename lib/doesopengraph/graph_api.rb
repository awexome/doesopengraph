# AWEXOME LABS
# DoesOpenGraph
#
# GraphAPI - Class containing get and post mechanism for accessing nodes
#  within the open graph
#

module DoesOpenGraph
  
  class OpenGraphException < Exception; end
  class IncapableOfUpdateMethods < OpenGraphException; end
  class InvalidRequestMethod < OpenGraphException; end
  class InvalidResponseFromFacebook < OpenGraphException; end

  
  
  class GraphAPI

    require "typhoeus"
    require "uri"
    require "json"
  
    HTTP_GRAPH_ENDPOINT = "http://graph.facebook.com/"
    HTTPS_GRAPH_ENDPOINT = "https://graph.facebook.com/"
    
    attr_reader :access_token, :history
  
    def initialize(acctok=nil)
      @access_token = acctok
      @history = Array.new
    end
    
    def renew(acctok)
      @access_token = acctok
    end
    
    
    def node(id, connection=nil, params={})
      path = connection.nil? ? id.to_s : File.join(id.to_s, connection.to_s)
      return request(:get, path, params)
    end
    alias_method :get, :node
    
  
    def update(id, connection, params={})
      return nil unless @access_token
      path = connection.nil? ? id.to_s : File.join(id.to_s, connection.to_s)
      return request(:post, path, params)
    end
    alias_method :post, :update
    
    
    def delete(id, connection=nil)
      return nil unless @access_token
      path = connection.nil? ? id.to_s : File.join(id.to_s, connection.to_s)
      return request(:delete, path)
    end
    

    def search(query, type, params={})
      return nil unless @access_token
      params[:q] = query.to_s
      params[:type] = type.to_s      
      request(:get, "search", params)
    end
    
    
    def num_requests
      @history.length
    end
    
    def previous_request
      @history.last
    end
    
    def repeat
      previous_request.request()
    end    
  
    
    
    private
    
    
    def request(method, path, params={})
      api_request = GraphRequest.new(self, method, path, params)
      @history << api_request
      return api_request.request()
    end
  

  end # GraphAPI    
end # DoesOpenGraph
      


