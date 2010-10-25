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

    def lang
      @i18n.iso_code
    end

    def method_missing(kw, *args, &block)
      # Need to call super or we'll get super (ha ha) weird errors
      if kw == :step
        @elements << [:step, step_to_i18n(args[0]), args[1]]
      elsif [:given, :when, :then, :and, :but].include?(kw)
        @elements << [:step, step_to_i18n(kw), args[0]]
      else # kw is for a container element
        @elements << [kw, kw_to_i18n(kw), args[0]]
        instance_eval(&block) if block_given?
      end
    end

    def to_gherkin
      out = StringIO.new
      pretty = Formatter::PrettyFormatter.new(out, true)
      @elements.each{ |element| model_from_element(element).replay(pretty) }
      out.rewind
      out.string
    end

    private

    def model_from_element(element)
      class_name = element[0]
      model_class = Formatter::Model.const_get(classify(element[0]))
      args = [[]] # Placeholder for comments
      
      sclass = model_class.superclass

      # FIXME: polymorphism like whoah. each statement class should be able to 
      # create itself from an element (which is secretly a sexp... sshhhhh)
      if sclass == Formatter::Model::TagStatement
        args.push([])
        args.push(*element[1..-1])
        args.push("")
      elsif sclass == Formatter::Model::DescribedStatement
        args.push(*element[1..-1])
        args.push("")
      elsif sclass == Formatter::Model::BasicStatement
        args.push(*element[1..-1])
      else
        raise "Can't make a model out of #{elements}."
      end
      args.push(-1) # placeholder line number
      model_class.new(*args)
    end

    def classify(sym)
      sym.to_s.split('_').map{|s| s.capitalize}.join
    end

    def step_to_i18n(adverb)
      # FIXME: I'm pretty sure this will break with langs that elide some letters (like French)
      # and in addition it should probably be moved into the i18n class itself like say in a 
      # translate(word) method. That would be mega-awesome.
      kws = @i18n.keywords(adverb)
      kws.delete("* ")
      kws.first
    end

    def kw_to_i18n(kw)
      @i18n.keywords(kw).first
    end
  end
end
