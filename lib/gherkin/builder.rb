module Gherkin
  class Builder
    attr_reader :elements

    def initialize(lang = "en", &block)
      @elements = []
      @i18n = I18n.get(lang)
      instance_eval(&block) if block_given?
    end

    def lang
      @i18n.iso_code
    end

    def method_missing(kw, *args, &block)
      if kw == :step
        @elements << [*extract_step(args[0])]
      else # kw is for a container element
        @elements << [kw_to_i18n(kw), args[0]]
      end
    end

    private

    def extract_step(step)
      parts = step.to_s.split
      [parts[0], parts[1..-1].join(" ")]
    end

    def kw_to_i18n(kw)
      @i18n.keywords(kw).first
    end
  end
end
