# frozen_string_literal: true

class PsulSearchBarComponent < Blacklight::SearchBarComponent
  def search_fields
    @search_fields ||= blacklight_config.search_fields.values
      .reject { |field_def| field_def&.include_in_simple_select == false }
      .map do |field_def|
      [field_def.dropdown_label || field_def.label,
       field_def.key,
       { 'data-placeholder' => field_def.placeholder_text || t('blacklight.search.form.search.placeholder') }]
    end
  end

  def before_render
    super
    return if @search_field

    @search_field = case params[:action]
                    when 'call_numbers'
                      case params[:classification]
                      when 'lc'
                        'browse_lc'
                      when 'dewey'
                        'browse_dewey'
                      end
                    when 'authors'
                      'browse_authors'
                    when 'subjects'
                      'browse_subjects'
                    when 'titles'
                      'browse_titles'
                    else
                      params[:search_field]
                    end
  end
end
