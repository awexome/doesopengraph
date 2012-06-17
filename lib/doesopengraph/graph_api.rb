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
  
  
    def node(id, connection=nil, params={})
      # Inject an access_token if we plan to make an authorized request:
      params[:access_token] = @access_token if @access_token
      
      # Stringify tokens:
      id = id.to_s
      connection = connection.to_s unless connection.nil?

      # Smoosh the URL components together:
      base = @access_token.nil? ? HTTP_GRAPH_ENDPOINT : HTTPS_GRAPH_ENDPOINT
      path = connection.nil? ? id : File.join(id, connection)
      href = File.join(base, path)
      
      # Make a request and parse JSON result:
      begin
        response = Typhoeus::Request.get(href, :params=>params)
        data = JSON.parse(response.body)
        return GraphNode.new(data, self)
      rescue JSON::ParserError => jsone
        raise "Invalid JSON or poorly formed JSON returned for #{path}" and return nil
      end
    end
    alias_method :get, :node


    def update(id, connection, params={})
      return nil unless @access_token
      params[:access_token] = @access_token
      
      # Smoosh the URL components together:
      base = HTTPS_GRAPH_ENDPOINT
      path = File.join(id, connection)
      href = File.join(base, path)
      
      # Make our POST request and check the results:
      begin
        response = Typhoeus::Request.post(href, :params=>params)
        data = JSON.parse(response.body)
        return GraphResponse.new(data)
      rescue JSON::ParserError => jsone
        # A JSON.parse on "true" triggers an error, so let's build it straight from body:
        return GraphResponse.new(response.body)
      end      
    end
    alias_method :post, :update


    def delete(id, connection=nil)
      return nil unless @access_token
      params = Hash.new and params[:access_token] = @access_token
      
      # Smoosh the URL components together:
      base = HTTPS_GRAPH_ENDPOINT
      path = connection.nil? ? id : File.join(id, connection)
      href = File.join(base, path)
      
      # Make our DELETE request and return the results:
      begin
        response = Typhoeus::Request.delete(href, :params=>params)
        data = JSON.parse(response.body)
        return GraphResponse.new(data)
      rescue JSON::ParserError => jsone
        # A JSON.parse on "true" triggers an error, so let's build it straight from body:
        return GraphResponse.new(response.body)
      end
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
      


