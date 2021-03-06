# frozen_string_literal: true

module ERBLint
  module Linters
    # Warns when a tag is not self-closed properly.
    class SelfClosingTagCustom < Linter
      include LinterRegistry

      class ConfigSchema < LinterConfig
        property :custom_message, accepts: String
      end
      self.config_schema = ConfigSchema

      CUSTOM_SELF_CLOSING_TAGS = %w(
        area input param track img
      )

      def run(processed_source)
        processed_source.ast.descendants(:tag).each do |tag_node|
          tag = BetterHtml::Tree::Tag.from_node(tag_node)
          next unless CUSTOM_SELF_CLOSING_TAGS.include?(tag.name)
          if tag.closing?
            start_solidus = tag_node.children.first
            add_offense(
                start_solidus.loc,
                "Tag `#{tag.name}` is self-closing, it must not start with `</`.",
                ''
            )
          end

          next if tag.self_closing?
          add_offense(
              tag_node.loc.end.offset(-1),
              "Tag `#{tag.name}` is self-closing, it must end with `/>`.",
              '/'
          )
        end
      end

      def autocorrect(_processed_source, offense)
        lambda do |corrector|
          corrector.replace(offense.source_range, offense.context)
        end
      end
    end
  end
end
