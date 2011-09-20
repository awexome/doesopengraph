# AWEXOME LABS
# DoesOpenGraph
#
# GraphRequest - A request to the OpenGraph API.
#

module DoesOpenGraph
  class GraphRequest

    attr_reader :api, :method, :path, :params
    
    # Build a Request object from its component parts
    def initialize(api, method, path, params={})
      @api = api
      @method = method
      @path = path
      @params = params
    end
    
    
    # Perform the request
    def request
      base = @api.access_token ? GraphAPI::HTTPS_GRAPH_ENDPOINT : GraphAPI::HTTP_GRAPH_ENDPOINT
      href = File.join(base, @path)
      
      if !%w(get post delete).include?(@method.to_s)
        raise InvalidRequestMethod.new("Invalid HTTP method #{@method} passed to request") and return nil
      end
      
      params[:access_token] = @api.access_token if @api.access_token
      
      begin
        response = Typhoeus::Request.send(@method, href, :params=>@params)
        puts "RESPONSE RECEIVED FROM FACEBOOK ON REQUEST TO PATH #{@path}:\n#{response.body}\n\n"
        
        return GraphResponse.new(response.body, self)
        
        # TODO: Parse known error responses from Facebook, such as:
        # TODO: {"error":{"message":"Unknown path components: \/status","type":"OAuthException"}}
        
      rescue Exception => e
        raise OpenGraphException.new("Error in OpenGraph response: #{e}") and return nil
      end
    end
    
    
    # Repeat the same request with optionally different parameters
    def repeat(params={})
      @params.merge(params)
      request()
    end
  

  end # GraphRequest
end # DoesOpenGraph
      


