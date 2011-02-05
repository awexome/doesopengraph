# AWEXOME LABS
# DoOpenGraph
#
# GraphAPI - Class containing get and post mechanism for accessing nodes
#  within the open graph
#

module DoOpenGraph
  class GraphAPI

    require 'typhoeus'

    require "net/http"
    require "net/https"
    require "uri"
    require "json"
  
    HTTP_GRAPH_ENDPOINT = "http://graph.facebook.com/"
    HTTPS_GRAPH_ENDPOINT = "https://graph.facebook.com/"
    
    attr_reader :access_token
  
    def initialize(acctok=nil)
      @access_token = acctok
    end
  
  
    def node(id, connection=nil, params={})
      # Inject an access_token if we plan to make an authorized request:
      params[:access_token] = @access_token if @access_token

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
      # Inject the access token if we have it and err if we don't
      return nil unless @access_token
      params[:access_token] = @access_token
      
      # Smoosh the URL components together:
      base = HTTPS_GRAPH_ENDPOINT
      path = File.join(id, connection)
      href = File.join(base, path)
      
      # Make our POST request and check the results:
      response = Typhoeus::Request.post(href, :params=>params)
      data = JSON.parse(response.body)
      return data
      
    end
    alias_method :post, :update
    
  

  end # GraphAPI    
end # DoOpenGraph
      


