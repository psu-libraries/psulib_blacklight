# frozen_string_literal: true

class DocumentRis
    attr_reader :docs

    FIELD_TYPES = {
        'Archives/Manuscripts' => 'GEN',
        'Article' => 'EJOUR',
        'Audio' => 'SOUND',
        'Book' => 'BOOK',
        'Equipment' => 'GEN',
        'Games/Toys' => 'GEN',
        'Government Document' => 'GOVDOC',
        'Image' => 'GEN',
        'Instructional Material' => 'GEN',
        'Journal/Periodical' => 'JOUR',
        'Juvenile Book' => 'BOOK',
        'Kit' => 'GEN',
        'Maps, Atlases, Globes' => 'MAP',
        'Microfilm/Microfiche' => 'GEN',
        'Musical Score' => 'MUSIC',
        'Newspaper' => 'NEWS',
        'Other' => 'GEN',
        'Proceeding/Congress' => 'CONF',
        'Reporter' => 'GEN',
        'Statute' => 'STAT',
        'Thesis/Dissertation' => 'THES',
        'Video' => 'VIDEO' }

  def initialize(document)
    @document = document
    @docs = @document.first['response']['docs'].first
  end

  def ris_to_string
    string = "TY  - #{type}\r\n" \
             "TI  - #{title}\r\n"  
    string += "A1  - #{primary_author}\r\n" if primary_author

    addl_authors&.each do |addl_author|
      string += "A2  - #{addl_author}\r\n"
    end

    string += "PY  - #{publication_year}\r\n" if publication_year
    string += "PP  - #{place_of_publication}\r\n" if place_of_publication
    string += "PB  - #{publisher_name}\r\n" if publisher_name
    string += "SN  - #{identifier}\r\n" if identifier
    string += "ET  - #{edition}\r\n" if edition
    string += "Y2  - #{access_date}\r\n"
    string += "UR  - #{url}\r\n"
    string += "ER  -\r\n"
    string
  end

  private

  def format
    docs['format'].first
  end

  def type 
    FIELD_TYPES[format] if FIELD_TYPES.key?(format)
  end

  def title
    docs['title_245ab_tsim'].first
  end

  def primary_author
    docs['author_tsim']&.first
  end

  def addl_authors
    docs['author_addl_tsim']
  end

  def publication_year
    docs['pub_date_illiad_ssm']&.first
  end

  def place_of_publication
    docs['publication_place_ssm']&.first
  end

  def publisher_name
    docs['publisher_name_ssm']&.first
  end

  def identifier
    return docs['issn_ssm'].first if docs['issn_ssm']
    docs['isbn_valid_ssm']&.first
  end

  def edition
    docs['edition_display_ssm']&.first
  end

  def url
    "https://catalog.libraries.psu.edu/catalog/#{docs['id']}"
  end

  def access_date
    Time.now.strftime("%Y-%m-%d")
  end
end