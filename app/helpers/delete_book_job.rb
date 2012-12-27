class DeleteBookJob < Struct.new(:book_id)
  def enqueue(job)

  end

  def perform
    book = Book.find(book_id)
    book.destroy
  end

  def before(job)
    puts 'before book delete'
  end

  def after(job)
    puts 'after book delete'
  end

  def success(job)
    puts "delete job successfully completed"
  end
end