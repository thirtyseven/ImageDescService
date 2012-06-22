class UserMailer < ActionMailer::Base
  default :from => "support@benentech.com"
  
  def book_uploaded_email(user, book)
   @user=user
   @book=book
   mail(to: user.email, subject: 'Poet Tool Book Uploaded')
  end
end
