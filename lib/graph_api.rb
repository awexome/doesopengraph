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
      if @access_token
        puts "Yes Access Token: #{access_token}"
        params[:access_token] = @access_token
      else
        puts "No Access Token"
      end

      # Smoosh the URL components together:
      base = @access_token.nil? ? HTTP_GRAPH_ENDPOINT : HTTPS_GRAPH_ENDPOINT
      path = connection.nil? ? id : File.join(id, connection)
      href = File.join(base, path)
      puts "REQUEST URL: #{href}"
      puts "REQUEST PARAMS: #{params.inspect}\n\n"
      
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
  
    def node2(id, connection=nil, opts={})
      opts = connection.dup and connection = nil if connection.is_a?(Hash)
      opts = {:access_token=>@access_token}.merge(opts) if @access_token
      nodepath = connection.nil? ? File.join(id) : File.join(id, connection)
      nodepath += "?#{opts.collect{|k,v| "#{k}=#{v}"}.join("=")}" unless opts.nil? || opts.empty?
      #base = @access_token.nil? ? URI.parse(HTTP_GRAPH_ENDPOINT) : URI.parse(HTTPS_GRAPH_ENDPOINT)
      base = URI.parse(HTTP_GRAPH_ENDPOINT)
      begin
        response = Net::HTTP.start(base.host, base.port) {|http| http.get(File.join("/",nodepath)) }
        data = JSON.parse(response.body)
        return GraphNode.new(data, self)
      rescue JSON::ParserError => jsone
        puts "JSON not returned for the requested node" and return nil
      end    
    end
    alias_method :get2, :node2
  
  
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
      


