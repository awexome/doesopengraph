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
    
  
    def update(id, connection, opts={})
      opts = {:access_token=>@access_token}.merge(opts) if @access_token
      nodepath = File.join(id, connection)
      begin
        response = Net::HTTP.post_form( URI.parse(File.join(HTTPS_GRAPH_ENDPOINT,nodepath)), opts )
      # rescue Exception => e
      #   return nil
      end
    end
    alias_method :post, :update

  end # GraphAPI    
end # DoOpenGraph
      


