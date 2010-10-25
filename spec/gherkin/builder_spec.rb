require 'spec_helper'

require 'gherkin/builder'

module Gherkin
  describe Builder do
    it "defaults to using en lang" do
      subject.lang.should == "en"
    end

    it "builds raw features" do
      subject.feature "foo"
      subject.elements.should == [["Feature", "foo"]]
    end

    it "builds raw scenarios" do
      subject.scenario "test"
      subject.elements.should == [["Scenario", "test"]]
    end

    it "builds raw backgrounds" do
      subject.background "bigger GBs"
      subject.elements.should == [["Background", "bigger GBs"]]
    end

    it "builds raw scenario outlines" do
      subject.scenario_outline "test 2"
      subject.elements.should == [["Scenario Outline", "test 2"]]
    end

    it "builds raw examples" do
      subject.examples "yet another example of the futility of something"
      subject.elements.should == [["Examples", "yet another example of the futility of something"]]
    end

    it "builds raw steps" do
      subject.step :given, "something else"
      subject.elements.should == [["Given", "something else"]]
    end

    it "builds raw steps with blocky sugar" do
      subject.build do |builder|
        builder.given "I have a sweet tooth"
        builder.when  "I pass a block with an arity of one"
        builder.then  "I can specify the adverb via the method name"
      end

      subject.elements.should == [
        ["Given", "I have a sweet tooth"],
        ["When",  "I pass a block with an arity of one"],
        ["Then",  "I can specify the adverb via the method name"]
      ]
    end
    
    it "builds containing and contained elements with delicious blocky sugar" do
      subject.build do
        feature "It will build you an island" do
          scenario "Cell mart" do |s|
            s.given "An Evo 4G"
            s.when  "iPhone 4s are sold out"
            s.then  "I need the one with the bigger GBs"
          end

          scenario "Apathy" do
            step :when, "It's out of date"
            step :then, "I don't care"
            step :and,  "I heard Walmart has them"
          end
        end
      end

      subject.elements.should == [
        ["Feature", "It will build you an island"],
        ["Scenario", "Cell mart"],
        ["Given", "An Evo 4G"],
        ["When", "iPhone 4s are sold out"],
        ["Then", "I need the one with the bigger GBs"],
        ["Scenario", "Apathy"],
        ["When", "It's out of date"],
        ["Then", "I don't care"],
        ["And", "I heard Walmart has them"]
      ]
    end
  end

  describe Builder, "with a specific language" do
    subject { Gherkin::Builder.new("no") }

    it "uses the translation for the keywords" do
      subject.build do
        feature "Foo"
        background "Bar"
        scenario "Baz"
        scenario_outline "Qux"
        examples "Quux"
        step :given, "Wibble"
      end

      subject.elements.should == [
        ["Egenskap", "Foo"],
        ["Bakgrunn", "Bar"],
        ["Scenario", "Baz"],
        ["Abstrakt Scenario", "Qux"],
        ["Eksempler", "Quux"],
        ["Gitt", "Wibble"]
      ]
    end
  end
end
