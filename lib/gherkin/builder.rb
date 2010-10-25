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

    def lang
      @i18n.iso_code
    end

    def method_missing(kw, *args, &block)
      # Need to call super or we'll get super (ha ha) weird errors
      if kw == :step
        @elements << [step_to_i18n(args[0]), args[1]]
      elsif [:given, :when, :then, :and, :but].include?(kw)
        @elements << [step_to_i18n(kw), args[0]]
      else # kw is for a container element
        @elements << [kw_to_i18n(kw), args[0]]
        instance_eval(&block) if block_given?
      end
    end

    private

    def step_to_i18n(adverb)
      # FIXME: I'm pretty sure this will break with langs that elide some letters (like French)
      # and in addition it should probably be moved into the i18n class itself like say in a 
      # translate(word) method. That would be mega-awesome.
      kws = @i18n.keywords(adverb)
      kws.delete("* ")
      kws.first.strip
    end

    def kw_to_i18n(kw)
      @i18n.keywords(kw).first
    end
  end
end
