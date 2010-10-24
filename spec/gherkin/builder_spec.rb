require 'spec_helper'

require 'gherkin/builder'

module Gherkin
  describe Builder do
    subject { Gherkin::Builder }
    
    it "defaults to using en lang" do
      subject.new.lang.should == "en"
    end

    it "builds raw features" do
      subject.new do
        feature "foo"
      end.elements.should == [["Feature", "foo"]]
    end

    it "builds raw scenarios" do
      subject.new do
        scenario "test"
      end.elements.should == [["Scenario", "test"]]
    end

    it "builds raw backgrounds" do
      subject.new do
        background "bigger GBs"
      end.elements.should == [["Background", "bigger GBs"]]
    end

    it "builds raw scenario outlines" do
      subject.new do
        scenario_outline "test 2"
      end.elements.should == [["Scenario Outline", "test 2"]]
    end

    it "builds raw examples" do
      subject.new do
        examples "yet another example of the futility of something"
      end.elements.should == [["Examples", "yet another example of the futility of something"]]
    end

    it "builds raw steps" do
      subject.new do
        step "Given something else"
      end.elements.should == [["Given", "something else"]]
    end
  end

  describe Builder, "with a specific language" do
    subject { Gherkin::Builder.new("no") }

    it "uses the translation for the keywords" do
      subject.feature "Foo"
      subject.background "Bar"
      subject.scenario "Baz"
      subject.scenario_outline "Qux"
      subject.examples "Quux"
      subject.elements.should == [
        ["Egenskap", "Foo"],
        ["Bakgrunn", "Bar"],
        ["Scenario", "Baz"],
        ["Abstrakt Scenario", "Qux"],
        ["Eksempler", "Quux"]
      ]
    end
  end
end
