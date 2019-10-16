# frozen_string_literal: true

readonly_settings = Rails.root.join('config', 'read_only.yml')
READONLY = YAML.load_file(readonly_settings) if File.file?(readonly_settings)
READONLY ||= { read_only: false }.freeze
