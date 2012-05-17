require 'spec_helper'

describe "book_fragments/show.html.erb" do
  before(:each) do
    @book_fragment = assign(:book_fragment, stub_model(BookFragment))
  end

  it "renders attributes in <p>" do
    render
  end
end
