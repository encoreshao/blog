# frozen_string_literal: true

module RougeHelper
  class HTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  def rouge_markdown(text)
    render_options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow" }
    }
    renderer = HTML.new(render_options)

    extensions = {
      autolink: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true
    }
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text)
  end

  def rouge(text, language)
    formatter = Rouge::Formatters::HTML.new(css_class: "highlight")
    lexer = Rouge::Lexer.find(language)
    formatter.format(lexer.lex(text))
  end
end
