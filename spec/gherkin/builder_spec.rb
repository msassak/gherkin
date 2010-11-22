require 'spec_helper'

require 'gherkin/builder'

module Gherkin
  describe Builder do
    it "defaults to the English translation" do
      subject.i18n_lang.should == "en"
    end

    it "builds raw features" do
      subject.feature "foo"
      subject.elements.should == [[:feature, "Feature", "foo"]]
    end

    it "builds raw scenarios" do
      subject.scenario "test"
      subject.elements.should == [[:scenario, "Scenario", "test"]]
    end

    it "builds raw backgrounds" do
      subject.background "bigger GBs"
      subject.elements.should == [[:background, "Background", "bigger GBs"]]
    end

    it "builds raw scenario outlines" do
      subject.scenario_outline "test 2"
      subject.elements.should == [[:scenario_outline, "Scenario Outline", "test 2"]]
    end

    it "builds raw examples" do
      subject.examples "yet another example of the futility of something"
      subject.elements.should == [[:examples, "Examples", "yet another example of the futility of something"]]
    end

    it "builds raw steps" do
      subject.step :given, "something else"
      subject.elements.should == [[:step, "Given ", "something else"]]
    end

    it "builds raw tags" do
      subject.feature "My Feature"
      subject.tags "foo"
      subject.tags :bar
      subject.tags ["baz", :qux], :quux
      subject.elements.should == [
        [:feature, ["foo", "bar", "baz", "qux", "quux"], "Feature", "My Feature"]
      ]
    end

    it "builds raw steps with blocky sugar" do
      subject.build do |builder|
        builder.given "I have a sweet tooth"
        builder.when  "I pass a block with an arity of one"
        builder.then  "I can specify the adverb via the method name"
      end

      subject.elements.should == [
        [:step, "Given ", "I have a sweet tooth"],
        [:step, "When ",  "I pass a block with an arity of one"],
        [:step, "Then ",  "I can specify the adverb via the method name"]
      ]
    end
    
    it "builds containing and contained elements with delicious blocky sugar" do
      subject.build do
        feature "It will build you an island" do
          tags %w[foo bar]

          scenario "Cell mart" do |s|
            s.given "An Evo 4G"
            s.when  "iPhone 4s are sold out"
            s.then  "I need the one with the bigger GBs"
            s.tags  "one"
            s.tags  [:two, "three"]
          end

          scenario "Apathy" do
            tags :baz
            step :when, "It's out of date"
            step :then, "I don't care"
            step :and,  "I heard Walmart has them"
          end
        end
      end

      subject.elements.should == [
        [:feature, ["foo", "bar"], "Feature", "It will build you an island"],
        [:scenario, ["one", "two", "three"], "Scenario", "Cell mart"],
        [:step, "Given ", "An Evo 4G"],
        [:step, "When ", "iPhone 4s are sold out"],
        [:step, "Then ", "I need the one with the bigger GBs"],
        [:scenario, ["baz"], "Scenario", "Apathy"],
        [:step, "When ", "It's out of date"],
        [:step, "Then ", "I don't care"],
        [:step, "And ", "I heard Walmart has them"]
      ]
    end

    describe "#to_gherkin" do
      it "outputs the feature in Gherkin format" do
        subject.build do 
          feature "LULZ" do
            scenario "Maglarble" do |s|
              s.given "a dog"
              s.and   "a fire hydrant"
              s.then  "maglarble!"
            end
          end
        end

        subject.to_gherkin.should == <<EOF
Feature: LULZ

  Scenario: Maglarble
    Given a dog
    And a fire hydrant
    Then maglarble!
EOF

      end
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
        [:feature, "Egenskap", "Foo"],
        [:background, "Bakgrunn", "Bar"],
        [:scenario, "Scenario", "Baz"],
        [:scenario_outline, "Scenariomal", "Qux"],
        [:examples, "Eksempler", "Quux"],
        [:step, "Gitt ", "Wibble"]
      ]
    end
  end
end
