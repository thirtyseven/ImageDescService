require 'spec_helper'

describe "book_fragments/index.html.erb" do
  before(:each) do
    assign(:book_fragments, [
      stub_model(BookFragment),
      stub_model(BookFragment)
    ])
  end

  it "renders a list of book_fragments" do
    render
  end
end
