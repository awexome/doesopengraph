# AWEXOME LABS
# DoesOpenGraph
#
# GraphAPI - Class containing get and post mechanism for accessing nodes
#  within the open graph
#

module DoesOpenGraph
  class GraphAPI

    require "typhoeus"
    require "uri"
    require "json"

    HTTP_GRAPH_ENDPOINT = "http://graph.facebook.com/"
    HTTPS_GRAPH_ENDPOINT = "https://graph.facebook.com/"

    attr_reader :access_token

    def initialize(acctok=nil)
      @access_token = acctok
    end

    def nodes(ids=[], connection=nil, params={})
      responses = []
      hydra = Typhoeus::Hydra.new
      
      ids.each do |id|
        request = node(id, connection, params, true)
        request.on_complete do |response|
          begin
            data = JSON.parse(response.body)
            responses << GraphNode.new(data, self)
          rescue JSON::ParserError => jsone
            raise "Invalid JSON or poorly formed JSON returned for #{path}" and return nil
          end
        end
        
        hydra.queue request

      end
      
      hydra.run
      responses
    end


    def node(id, connection=nil, params={}, queue=false)
      # Inject an access_token if we plan to make an authorized request:
      params[:access_token] = @access_token if @access_token

      # Stringify tokens:
      id = id.to_s
      connection = connection.to_s unless connection.nil?

      # Smoosh the URL components together:
      base = @access_token.nil? ? HTTP_GRAPH_ENDPOINT : HTTPS_GRAPH_ENDPOINT
      path = connection.nil? ? id : File.join(id, connection)
      href = File.join(base, path)

      if queue
        return Typhoeus::Request.new(href, :params=>params)
      else
        # Make a request and parse JSON result:
        begin
          response = Typhoeus::Request.get(href, :params=>params)
          data = JSON.parse(response.body)
          return GraphNode.new(data, self)
        rescue JSON::ParserError => jsone
          raise "Invalid JSON or poorly formed JSON returned for #{path}" and return nil
        end
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
      # Inject the access token if we have it and err if we don't
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
      # Inject the access token if we have it and err if we don't
      return nil unless @access_token
      params[:access_token] = @access_token

      # Build the search query and its target:
      params[:q] = query
      params[:type] = type
      href = File.join(HTTPS_GRAPH_ENDPOINT, "search")

      # Make the request:
      response = Typhoeus::Request.get(href, :params=>params)
      data = JSON.parse(response.body)
      return GraphResponse.new(data)
    end



  end # GraphAPI
end # DoesOpenGraph

