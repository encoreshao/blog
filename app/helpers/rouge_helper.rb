module RougeHelper
  def rouge(text, language)
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')
    lexer = Rouge::Lexer.find(language)
    formatter.format(lexer.lex(text))
  end
end
