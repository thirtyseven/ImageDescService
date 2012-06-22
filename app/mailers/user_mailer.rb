class UserMailer < ActionMailer::Base
  default :from => "do-not-reply@benetech.org"
  
  def book_uploaded_email(user, book)
   @user=user
   @book=book
   mail(to: user.email, subject: 'Poet book upload completed')
  end
end
