require 'stringio'
require 'gherkin/formatter/pretty_formatter'
require 'gherkin/formatter/model'

module Gherkin
  class Builder
    attr_reader :elements

    def initialize(lang = "en", &block)
      @elements = []
      @i18n = I18n.get(lang)
      instance_eval(&block) if block_given?
    end

    def build(&block)
      instance_eval(&block)
      self
    end

    def i18n_lang
      @i18n.iso_code
    end

    def method_missing(kw, *args, &block)
      if kw == :step
        elements << build_hash(:step, translate(args[0]), args[1], 
                               :multiline_arg => args[2])

      elsif [:given, :when, :then, :and, :but].include?(kw)
        elements << build_hash(:step, translate(kw), args[0])

      elsif describable.include?(kw)
        elements << build_hash(kw, translate(kw), args[0])
        instance_eval(&block) if block_given?

      elsif kw == :description
        last = elements.reverse.find{|el| describable.include?(el[:type])}
        last[:description] = args[0]

      elsif kw == :tags
        tags = args.flatten.map{|tag| "@#{tag.to_s}"} 
        last = elements.reverse.find{|el| taggable.include?(el[:type])}
        last[:tags] << tags
        last[:tags].flatten!

      elsif kw == :row
        last = elements.reverse.find{|el| el[:type] == :examples}
        last[:rows] << args[0]

      else
        super(kw, *args, &block)
      end
    end

    def to_gherkin
      out = StringIO.new
      pretty = Formatter::PrettyFormatter.new(out, true)
      add_language_pragma(i18n_lang, elements[0]) if i18n_lang != "en"
      elements.each{ |element| Formatter::Model.from_hash(element).replay(pretty) }
      out.rewind
      out.string
    end

    def to_sexps
      elements.collect do |element| 
        sexp = element.values_at(:type, :keyword, :name)
        sexp << element[:description]   unless element[:description].empty?
        sexp << element[:tags]          unless element[:tags].empty?
        sexp << element[:multiline_arg] unless element[:multiline_arg].nil?
        sexp
      end
    end

    private

    def translate(word)
      @i18n.translate(word)
    end

    def taggable
      [:feature, :scenario, :scenario_outline, :examples]
    end

    def describable
      [:feature, :background, :scenario, :scenario_outline, :examples]
    end

    def build_hash(type, keyword, name, opts={})
      {
        :type          => type,
        :keyword       => keyword,
        :name          => name,
        :description   => "",
        :line          => -1,
        :comments      => [],
        :tags          => [],
        :rows          => [],
        :multiline_arg => nil
      }.merge(opts)
    end

    def add_language_pragma(lang, element)
      element[:comments] << Formatter::Model::Comment.new("# language: #{lang}", -1)
    end
  end
end
