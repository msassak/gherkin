require 'spec_helper'

require 'gherkin/builder'

module Gherkin
  describe Builder do
    it "defaults to the English translation" do
      subject.i18n_lang.should == "en"
    end

    it "builds raw features" do
      subject.feature "foo"
      subject.to_sexps.should == [[:feature, [], "Feature", "foo", ""]]
    end

    it "builds raw scenarios" do
      subject.scenario "test"
      subject.to_sexps.should == [[:scenario, [], "Scenario", "test", ""]]
    end

    it "builds raw backgrounds" do
      subject.background "bigger GBs"
      subject.to_sexps.should == [[:background, [], "Background", "bigger GBs", ""]]
    end

    it "builds raw scenario outlines" do
      subject.scenario_outline "test 2"
      subject.to_sexps.should == [[:scenario_outline, [], "Scenario Outline", "test 2", ""]]
    end

    it "builds raw examples" do
      subject.examples "yet another example of the futility of something"
      subject.to_sexps.should == [[:examples, [], "Examples", "yet another example of the futility of something", ""]]
    end

    it "builds raw steps" do
      subject.step :given, "something else"
      subject.to_sexps.should == [[:step, [], "Given ", "something else", ""]]
    end

    it "builds raw tags" do
      subject.feature "My Feature"
      subject.tags "foo"
      subject.tags :bar
      subject.tags ["baz", :qux], :quux
      subject.to_sexps.should == [
        [:feature, ["@foo", "@bar", "@baz", "@qux", "@quux"], "Feature", "My Feature", ""]
      ]
    end
    
    it "builds raw descriptions" do
      subject.scenario "Another Scenario"
      subject.description "Descriptions > comments"
      subject.to_sexps.should == [
        [:scenario, [], "Scenario", "Another Scenario", "Descriptions > comments"]
      ]
    end

    it "builds raw steps with blocky sugar" do
      subject.build do |builder|
        builder.given "I have a sweet tooth"
        builder.when  "I pass a block with an arity of one"
        builder.then  "I can specify the adverb via the method name"
      end

      subject.to_sexps.should == [
        [:step, [], "Given ", "I have a sweet tooth", ""],
        [:step, [], "When ",  "I pass a block with an arity of one", ""],
        [:step, [], "Then ",  "I can specify the adverb via the method name", ""]
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

      subject.to_sexps.should == [
        [:feature, ["@foo", "@bar"], "Feature", "It will build you an island", ""],
        [:scenario, ["@one", "@two", "@three"], "Scenario", "Cell mart", ""],
        [:step, [], "Given ", "An Evo 4G", ""],
        [:step, [], "When ", "iPhone 4s are sold out", ""],
        [:step, [], "Then ", "I need the one with the bigger GBs", ""],
        [:scenario, ["@baz"], "Scenario", "Apathy", ""],
        [:step, [], "When ", "It's out of date", ""],
        [:step, [], "Then ", "I don't care", ""],
        [:step, [], "And ", "I heard Walmart has them", ""]
      ]
    end

    describe "#to_gherkin" do
      it "outputs the feature in Gherkin format" do
        subject.build do 
          feature "LULZ" do
            tags "foo"
            description "If there was a problem\nYo I'll solve it\nCheck out the hook\nWhile my DJ revolves it"

            scenario "Maglarble" do |s|
              s.tags [:bar, "baz", "qux"]
              s.given "a dog"
              s.and   "a fire hydrant"
              s.then  "maglarble!"
            end

            scenario_outline "The Facts of the Matter" do
              step :given, "a <weapon>"
              step :and,   "a <motive>"
              step :then,  "an <outcome>"

              examples "Get a Clue" do
                row %w(weapon motive outcome)
                row %w(candlestick jealousy jail)
                row %w(financial_instruments greed bailout)
              end
            end
          end
        end

        subject.to_gherkin.should == <<EOF
@foo
Feature: LULZ
  If there was a problem
  Yo I'll solve it
  Check out the hook
  While my DJ revolves it

  @bar @baz @qux
  Scenario: Maglarble
    Given a dog
    And a fire hydrant
    Then maglarble!

  Scenario Outline: The Facts of the Matter
    Given a <weapon>
    And a <motive>
    Then an <outcome>

    Examples: Get a Clue
      | weapon                | motive   | outcome |
      | candlestick           | jealousy | jail    |
      | financial_instruments | greed    | bailout |
EOF

      end
    end

    context "with a specific language" do
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

        subject.to_sexps.should == [
          [:feature, [], "Egenskap", "Foo", ""],
          [:background, [], "Bakgrunn", "Bar", ""],
          [:scenario, [], "Scenario", "Baz", ""],
          [:scenario_outline, [], "Scenariomal", "Qux", ""],
          [:examples, [], "Eksempler", "Quux", ""],
          [:step, [], "Gitt ", "Wibble", ""]
        ]
      end

      describe "#to_gherkin" do
        it "includes the language pragma comment" do
          subject.build{ feature "Lutefisk" }.to_gherkin.should == "# language: no\nEgenskap: Lutefisk\n"
        end
      end
    end
  end
end
