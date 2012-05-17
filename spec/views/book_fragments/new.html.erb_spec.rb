require 'spec_helper'

describe "book_fragments/new.html.erb" do
  before(:each) do
    assign(:book_fragment, stub_model(BookFragment).as_new_record)
  end

  it "renders new book_fragment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => book_fragments_path, :method => "post" do
    end
  end
end
