# AWEXOME LABS
# DoesOpenGraph
#
# Rakefile

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "doesopengraph"
    gem.summary = "The Awexome Labs library for accessing and manipulating the Facebook OpenGraph"
    gem.description = "Content-type-agnostic library for accessing and manipulating the Facebook OpenGraph with all major methods and search"
    gem.files = Dir["{lib}/**/*"]
    gem.email = "info@awexomelabs.com"
    gem.homepage = "http://awexomelabs.com/"
    gem.authors = ["mccolin"]
    gem.version = File.exist?('VERSION') ? File.read('VERSION') : "NOVERSION"

    # DoesOpenGraph depends on Typhoeus for communication:
    gem.add_dependency "typhoeus", ">=0.2.0"
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end
