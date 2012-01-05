class UpdateReportsJob
  def enqueue(job)

  end

  def perform
    Book.find_each do |book|
      BookStats.create_book_row(book)
    end
  end
end