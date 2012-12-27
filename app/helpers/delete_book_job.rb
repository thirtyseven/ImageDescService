class DeleteBookJob < Struct.new(:book_id)
  def enqueue(job)

  end

  def perform
    book = Book.find(book_id)
    book.destroy
  end
end