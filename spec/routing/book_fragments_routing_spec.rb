require "spec_helper"

describe BookFragmentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/book_fragments" }.should route_to(:controller => "book_fragments", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/book_fragments/new" }.should route_to(:controller => "book_fragments", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/book_fragments/1" }.should route_to(:controller => "book_fragments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/book_fragments/1/edit" }.should route_to(:controller => "book_fragments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/book_fragments" }.should route_to(:controller => "book_fragments", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/book_fragments/1" }.should route_to(:controller => "book_fragments", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/book_fragments/1" }.should route_to(:controller => "book_fragments", :action => "destroy", :id => "1")
    end

  end
end
