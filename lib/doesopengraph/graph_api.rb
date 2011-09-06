# AWEXOME LABS
# DoesOpenGraph
#
# GraphAPI - Class containing get and post mechanism for accessing nodes
#  within the open graph
#

module DoesOpenGraph
  
  class OpenGraphException < Exception; end
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
      method, path, params = @history.last
      return {:method=>method, :path=>path, :params=>params}
    end
    
    def repeat
      pr = previous_request
      return request(pr[:method], pr[:path], pr[:params])
    end    
  
    
    
    private
    
    
    def request(method, path, params={})
      @history << [method, path, params]
      
      base = @access_token.nil? ? HTTP_GRAPH_ENDPOINT : HTTPS_GRAPH_ENDPOINT
      href = File.join(base, path)
      
      if !%w(get post delete).include?(method.to_s)
        raise "Invalid HTTP method #{method} passed to request" and return nil
      end
      
      params[:access_token] = @access_token if @access_token
      
      begin
        response = Typhoeus::Request.send(method, href, :params=>params)
        data = JSON.parse(response.body)
        return GraphResponse.new(data, self) if path == "search"
        return GraphNode.new(data, self)
      rescue JSON::ParserError => jsone
        return true if response.body == "true"
        return false if response.body == "false"
        raise InvalidResponseFromFacebook.new("Invalid JSON or poorly formed JSON returned for #{path}") and return nil
      rescue Exception => e
        raise OpenGraphException.new("Error in OpenGraph response: #{e}") and return nil
      end      
    end

    
  

  end # GraphAPI    
end # DoesOpenGraph
      


