require 'spec_helper'

describe "book_fragments/edit.html.erb" do
  before(:each) do
    @book_fragment = assign(:book_fragment, stub_model(BookFragment))
  end

  it "renders the edit book_fragment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => book_fragments_path(@book_fragment), :method => "post" do
    end
  end
end
