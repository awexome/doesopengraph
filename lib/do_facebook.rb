# AWEXOME
# DoFacebook - meat and potatoes

class DoFacebook

  require "net/http"
  require "uri"
  require "json"
  
  API_GRAPH_ENDPOINT = "http://graph.facebook.com/"
  
  def initialize(acctok=nil)
    @access_token = acctok
  end
  
  def node(id, connection=nil, opts={})
    opts = connection.dup and connection = nil if connection.is_a?(Hash)
    opts = {:access_token=>@access_token}.merge(opts) if @access_token
    nodepath = connection.nil? ? File.join(id) : File.join(id, connection)
    nodepath += "?#{opts.collect{|k,v| "#{k}=#{v}"}.join("=")}" unless opts.nil? || opts.empty?
    base = URI.parse(API_GRAPH_ENDPOINT)
    begin
      response = Net::HTTP.start(base.host, base.port) {|http| http.get(File.join("/",nodepath)) }
      return data = JSON.parse(response.body)
    rescue JSON::ParserError => jsone
      puts "JSON not returned for the requested node" and return nil
    end    
  end
  alias_method :get, :node

    
end #DoFacebook
      


