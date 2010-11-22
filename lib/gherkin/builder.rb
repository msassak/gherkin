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
    end

    def i18n_lang
      @i18n.iso_code
    end

    def method_missing(kw, *args, &block)
      # Need to call super or we'll get super (ha ha) weird errors
      if kw == :step
        elements << [:step, translate(args[0]), args[1]]
      elsif [:given, :when, :then, :and, :but].include?(kw)
        elements << [:step, translate(kw), args[0]]
      elsif kw == :tags
        # insert_tags_into_last_container(tags)
        tags = args.flatten.map{|tag| tag.to_s}
        last_container = elements.reverse.find{|el| container_elements.include?(el[0])}
        last_container.insert(1, []) unless last_container[1].is_a? Array
        last_container[1] << tags
        last_container[1].flatten!
      else # kw is for a container element
        elements << [kw, translate(kw), args[0]]
        instance_eval(&block) if block_given?
      end
    end

    def to_gherkin
      out = StringIO.new
      pretty = Formatter::PrettyFormatter.new(out, true)
      elements.each{ |element| Formatter::Model.from_raw(element).replay(pretty) }
      out.rewind
      out.string
    end

    private

    def translate(word)
      @i18n.translate(word)
    end

    def container_elements
      [:feature, :scenario, :scenario_outline, :examples]
    end
  end
end
