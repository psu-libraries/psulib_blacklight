# frozen_string_literal: true

# == Transformation conventions
# The main use case for extensions is for transforming a Document to another
# format. Either to another type of Ruby object, or to an exportable string in
# a certain format.
#
# The convention for methods contained in extensions that transform to a ruby
# object is "to_*".  For instance, "to_marc" would return a Ruby Marc object.
#
# The convention for methods contained in extensions that transform to an
# exportable file of some kind is "export_as_*".  For instance,
# "export_as_marc21" would return a String object containing valid marc21, and
# "export_as_marcxml" would return a String object containing valid marcxml.
#
# The tokens used after "export_as" should normally be the format names as
# registered with Rails Mime::Type.
#
# == Advertising export formats
#
# If an extension advertises what export formats it can provide, than those
# formats will automatically be delivered by the Blacklight catalog/show
# controller, and potentially automatically advertised in various places
# that advertise available formats. (HTML link rel=alternate; Atom
# link rel=alterate; etc).
#
# Export formats are 'registered' by calling the #will_export_as method
# on a Document instance. An extension would usually do this in a
# self.extended method, so it can be called on Documents that have
# the given extension added to them. For instance:
#
#   module DemoMarcExtension
#     def self.extended(document)
#       document.will_export_as(:marc21, "application/marc")
#       document.will_export_as(:marcxml, "application/marcxml+xml")
#     end
#
#     def export_as_marc21 ; something ; end
#     def export_as_marcxml ; something ; end
#   end
#
module Blacklight::Document::Export
    include Blacklight::Searchable
    ##
    # Register exportable formats supported by the individual document.
    # Usually called by an extension in it's self.extended method, to
    # register the formats that extension can export.
    #
    # some_document.will_export_as(:some_format, "application/type") means
    # that the document (usually via an extension) has a method
    # "export_as_some_format" which returns a String of content that
    # is described by the mime content_type given.
    #
    # The format name should ideally _already_ be registered with
    # Rails Mime::Type, in your application initializer, representing
    # the content type given.  However, this method will attempt to
    # register it using Mime::Type.register_alias if it's not previously
    # registered. This is a bit sketchy though.
    def will_export_as(short_name, content_type = nil)
      # Lookup in Rails Mime::Type, register if needed, otherwise take
      # content-type from registration if needed.
      if defined?(Mime) && Mime[short_name.to_sym]
        content_type ||= Mime[short_name.to_sym]
      else
        # not registered, we need to register. Use register_alias to be least
        # likely to interfere with host app.
        Mime::Type.register_alias(content_type, short_name)
      end
  
      export_formats[short_name] = { content_type: content_type }
    end
  
    # Collects formats that this doc can export as.
    # To see if a given export format is supported by this document,
    # simply call document.export_formats.keys.include?(:my_format)
    # Then call #export_as! to do the export.
    # @return [Hash{Symbol=>Hash{Symbol=>String}}] keys are format short-names that can be exported, values are Hashes
    # @example { :marc => { content_type: 'application/marc' } }
    def export_formats
      @export_formats ||= {}
    end
  
    # Call with a format shortname, export_as(:marc), simply returns
    # #export_as_marc . Later we may expand the design to allow you
    # to register an arbitrary method name instead of insisting
    # on the convention, so clients should call this method so
    # they'll still keep working if we do that.
    def export_as(short_name)
      send("export_as_#{short_name}")
    end
  
    def exports_as? short_name
      respond_to? "export_as_#{short_name}"
    end

    def self.register_export_formats(document)
        document.will_export_as(:xml)
        document.will_export_as(:marc, "application/marc")
        # marcxml content type:
        # http://tools.ietf.org/html/draft-denenberg-mods-etc-media-types-00
        document.will_export_as(:marcxml, "application/marcxml+xml")
        document.will_export_as(:openurl_ctx_kev, "application/x-openurl-ctx-kev")
        document.will_export_as(:refworks_marc_txt, "text/plain")
        document.will_export_as(:endnote, "application/x-endnote-refer")
        document.will_export_as(:ris, "application/ris")
      end

    def export_as_openurl_ctx_kev(format = nil)
        format = self[:format]
        format = format.is_a?(Array) ? format[0].downcase.strip : format.downcase.strip if format.present?
    
        context_object = OpenURL::ContextObject.new

        if format == 'Book'
          context_object.referent.set_format('book')
          metadata = {
            'genre' => 'book',
            'title' => self[:title_display_ssm],
            'btitle' => self[:title_display_ssm],
            'au' => self[:author_person_display_ssm],
            #'date' => self[:pub_date_isim],
            #'place' => self[:publisher_location_ssim],
            'pub' => self[:publication_display_ssm],
            'edition' => self[:edition_display_ssm],
            'isbn' => self[:isbn_valid_ssm]
          }
        else
          context_object.referent.set_format('dc')
          metadata = {
            'genre' => 'dc',
            'title' => self[:title_display_ssm],
            'creator' => self[:author_person_display_ssm],
            #'date' => self[:pub_date_isim],
            #'place' => self[:publisher_location_ssim],
            'pub' => self[:publication_display_ssm]
          }
        end
    
        metadata.each do |key, value|
          data = value.is_a?(Array) ? value&.first.to_s : value.to_s
          context_object.referent.set_metadata(key, data.strip)
        end
    
        context_object.kev
      end
  end