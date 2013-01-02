DELIMITER $$
  DROP PROCEDURE IF EXISTS `delete_book` $$
  CREATE PROCEDURE `delete_book`(IN bookId INT)
    BEGIN
      delete from dynamic_descriptions where book_id = bookId;
      delete from dynamic_images where book_id = bookId;
      delete from book_fragments where book_id = bookId;
      delete from book_stats where book_id = bookId;
      delete from books where id = bookId;
    END $$
  DELIMITER ;