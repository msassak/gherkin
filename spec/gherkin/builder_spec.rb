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
