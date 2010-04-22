# AWEXOME
# DoFacebook - initializer

require 'do_facebook'

require 'utils'
require 'do_document_fields'
ActiveRecord::Base.class_eval do
  include Awexome::Do::DocumentFields
end

