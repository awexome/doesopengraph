# AWEXOME LABS
# DoesOpenGraph
#
# GraphResponse - A very simple wrapper for data returned by the OpenGraph API
#

module DoesOpenGraph
  class GraphResponse

    attr_reader :content, :object, :request

    # Build a Response object from raw JSON HTTP response
    def initialize(raw_content, request=nil)
      @request = request
      self.update(raw_content)
    end
    
    # Update the stored content of this node and parse
    def update (raw_content)
      @content = raw_content
      self.parse
    end
    
    # Parse the stored raw content and translate into a usable object
    def parse
      begin
        parsed_content = JSON.parse(@content)
        @object = parsed_content.is_a?(Hash) ? Hashie::Mash.new(parsed_content) : parsed_content
    
      rescue JSON::ParserError => parse_error
        @object = nil
        if parse_error.message.match("unexpected token")
          @object = true if @content == "true"
          @object = false if @content == "false"
        end
        if @object.nil?
          raise InvalidResponseFromFacebook.new("Invalid JSON returned from Facebook: #{parse_error.message}")
        end
      end
    end

    
    # Update this node from theFetch an updated view of this node
    def reload
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      up = request.request()
      @content = up.content
      @object = up.object
      return self
    end
    
    # Is this response an error?
    def error?
      keys.include?(:error)
    end
    
    # What is the error return from Facebook in this response?
    def error_message
      @object.error ? @object.error.message : nil
    end
    
    # Introspect on the connections available to this node
    def introspect
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      request.repeat(:metadata=>1)
    end
    
    # Get a connection of this node
    def get(connection, params={})
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      request.api.get(object.id, connection, params)
    end
    
    # Post to a connection of this node
    def post(connection, params={})
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      request.api.post(object.id, connection, params)
    end
    
    
    # Load the next page of the response if paging is available
    def next_page; page("next"); end
    def previous_page; page("previous"); end
        
    # Load a specific page of results if available:
    def page(pg, pp=25)
      if pg.is_a?(String)
        if object.paging 
          if page_url = object.paging[pg]
            data = page_url.match(/\?(\S+)/)[1].split("&").collect{|pair| pair.split("=")}.select{|k,v| k!="access_token"}
            params = Hash.new
            data.each {|k,v| params[k.to_sym] = v}
            return request.repeat(params)
          end
        end
      else
        return request.repeat(:limit=>pp, :offset=>(pg-1)*pp)
      end
      return nil
    end
    
    
    # Delete this node from the graph
    def delete
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      request.api.delete(object.id)
    end
    
    # Like this node, if supported
    def like
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      request.api.post(object.id, "likes")
    end
    
    # Unlike this node, if supported
    def unlike
      raise IncapableOfUpdateMethods.new("Cannot update content without stored request") if request.nil?
      request.api.delete(object.id, "likes")
    end

    
    # What keys are available on this OpenGraph node?
    def keys
      object.is_a?(Hash) ? object.keys.collect{|k|k.to_sym} : Array.new
    end
    
    # Include our return top-level keys in the methods list:
    def methods()
      keys + super()
    end
    
    # Use method-missing to provide top-level keys of response Hash as methods
    def method_missing(m, *args, &block)
      object.include?(m.to_s) ? object.send(m.to_s) : super(m, args)
    end

  end # GraphResponse    
end # DoesOpenGraph
      


