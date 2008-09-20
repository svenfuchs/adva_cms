require File.dirname(__FILE__) + "/../../spec_helper"
require 'widgets'

describe 'Widgets' do
  describe "widget_conditions_satisfied?" do
    describe "with :only" do
      before :each do
        @options = {:only => {:controller => :match, :action => [:match, :neverexists]}}
      end

      describe "with the controllers matching" do
        describe "with one of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :match, :action => :match
          end
          it "should yield to true" do
            template.widget_conditions_satisfied?(@options).should be_true
          end
        end

        describe "with none of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :match, :action => :nomatch
          end
          it "should yield to false" do
            template.widget_conditions_satisfied?(@options).should be_false
          end
        end
      end

      describe "with the controllers not matching" do
        describe "with one of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :nomatch, :action => :match
          end
          it "should yield to false" do
            template.widget_conditions_satisfied?(@options).should be_false
          end
        end

        describe "with none of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :nomatch, :action => :nomatch
          end
          it "should yield to false" do
            template.widget_conditions_satisfied?(@options).should be_false
          end
        end
      end
    end

    describe "widget_condition_satisfied with :except" do
      before :each do
        @options = {:except => {:controller => :match, :action => [:match, :neverexists]}}
      end

      describe "with the controllers matching" do
        describe "with one of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :match, :action => :match
          end
          it "should yield to false" do
            template.widget_conditions_satisfied?(@options).should be_false
          end
        end

        describe "with none of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :match, :action => :nomatch
          end
          it "should yield to true" do
            template.widget_conditions_satisfied?(@options).should be_true
          end
        end
      end

      describe "with the controllers not matching" do
        describe "with one of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :nomatch, :action => :match
          end
          it "should yield to true" do
            template.widget_conditions_satisfied?(@options).should be_true
          end
        end

        describe "with none of the actions matching" do
          before :each do
            template.stub!(:params).and_return :controller => :nomatch, :action => :nomatch
          end
          it "should yield to true" do
            template.widget_conditions_satisfied?(@options).should be_true
          end
        end
      end
    end
  end
end