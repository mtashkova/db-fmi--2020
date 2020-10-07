USE library 

--1.simple queries---

--1.1.Заявка, която извежда заглавията, годините на публикуване и езика на книгите, чиито автор е 'Stephen King'.
SELECT TITLE, YEAR, LANGUAGE
FROM BOOK
WHERE AUTHOR_NAME = 'Stephen King';

--1.2.Заявка, която извежда заглавията на книгите, които се състоят от точно 2 думи.
SELECT TITLE
FROM BOOK
WHERE TITLE LIKE '% %' AND TITLE NOT LIKE '% % %';

--1.3.Заявка, която извежда имената, рождените дати и националностите, на авторите, които са мъже и годината им на раждане е по-голяма от 1950 г.
SELECT NAME, BIRTHDATE, NATIONALITY
FROM AUTHOR
WHERE GENDER = 'M' AND YEAR(BIRTHDATE) > 1950;

--1.4.. Заявка, която извежда името и пола на библиотекарите.
SELECT NAME, IIF(SUBSTRING(LIBRARIAN.EGN, 9, 1) % 2 = 0, 'M', 'F') AS GENDER
FROM LIBRARIAN;

--1.5. Заявка, която извежда идентификационен номер на книгата и с колко дни е закъсняло връщането и.
SELECT BOOK_ID, DATEDIFF(day, BORROWING.DUE_DATE, GETDATE()) AS DELAY_IN_DAYS
FROM BORROWING
WHERE RETURN_DATE IS NULL AND GETDATE() > BORROWING.DUE_DATE
ORDER BY DELAY_IN_DAYS;

--1.6. Заявка, която извежда името и възрастта на непълнолетните читатели.
SELECT NAME, DATEDIFF(year, dbo.GET_BIRTHDATE(EGN), GETDATE()) AS AGE
FROM MEMBER
WHERE DATEDIFF(year, dbo.GET_BIRTHDATE(EGN), GETDATE()) < 18
ORDER BY AGE DESC;

--2.many relations--

--2.1.Заявка, която извежда заглавията на книгите и имената на библиотекарите, които отговарят за тях, сортирани по заглавие на книгата.
SELECT DISTINCT BOOK.TITLE, LIBRARIAN.NAME
FROM LIBRARIAN, BOOK
WHERE LIBRARIAN.SECTOR = BOOK.GENRE
ORDER BY TITLE;

--2.2. Заявка, която извежда името и егн-то на тези хора, които са библиотекари и читатели едновременно.
(SELECT NAME, EGN FROM MEMBER)
INTERSECT
(SELECT NAME, EGN FROM LIBRARIAN);

--2.3. Заявка, която извежда имената на авторите родени след 1960 г. и имат книга с повече от 200 страници.
(SELECT AUTHOR_NAME FROM BOOK WHERE PAGES_NUMBER > 200)
INTERSECT
(SELECT NAME FROM AUTHOR WHERE YEAR(BIRTHDATE) > 1960);

--2.4 Заявка, която извежда имената на читателите и библиотекари, които живеят във Варна.
(SELECT 'Librarian' as Type, NAME FROM LIBRARIAN WHERE ADDRESS LIKE '%Varna%')
UNION
(SELECT 'Member' as Type, NAME FROM MEMBER WHERE ADDRESS LIKE '%Varna%');

--2.5. Заявка, която извежда имената и адресите на читателите, за които има друг читател, които живее на същия адрес и ги сортира по адрес.
SELECT M1.NAME, M1.ADDRESS
FROM MEMBER M1, MEMBER M2
WHERE M1.EGN != M2.EGN AND M1.ADDRESS = M2.ADDRESS
ORDER BY M1.ADDRESS;

--3.subqueries--

--3.1. Заявка, която показва читателите, които са взели поне една книга в момента.
SELECT NAME
FROM MEMBER
WHERE EGN IN (SELECT DISTINCT MEMBER_EGN
		      FROM BORROWING
			  WHERE RETURN_DATE IS NULL);


--***3.2. Заявка, която извежда всички книги, които не са вземани никога.
SELECT DISTINCT TITLE,isbn, PUBLISHER_NAME
FROM BOOK
WHERE ISBN IN (SELECT ISBN FROM BOOK
			   EXCEPT
			   SELECT ISBN FROM BORROWING_ISBN);

--3.3. Заявка, която извежда от коя националност авторите, имат най-голям брой книги.
SELECT DISTINCT NATIONALITY
FROM AUTHOR
WHERE NAME IN (SELECT AUTHOR_NAME 
			   FROM (SELECT AUTHOR_NAME,COUNT(*) as c	
					 FROM BOOK 
					 GROUP BY AUTHOR_NAME) as tab
				     WHERE tab.c=(SELECT max(tab.c) 
					              FROM (SELECT AUTHOR_NAME,COUNT(*) as c	
								        FROM BOOK
										GROUP BY AUTHOR_NAME)as tab));

--3.4. Заявка, която извежда имената на издателствата, имената на книгите, които са издадени през нечетни години и по-късно от последната издадена книга на ‘Ivan Vazov’.
SELECT PUBLISHER_NAME,TITLE, YEAR
FROM BOOK
WHERE YEAR%2=1 AND YEAR > (SELECT MAX(YEAR) FROM BOOK WHERE AUTHOR_NAME = 'Ivan Vazov');

--3.5. Заявка, която извежда рождената дата и имената на авторите, които са написали романи с над 200 стр.
SELECT NAME, BIRTHDATE
FROM AUTHOR
WHERE NAME IN (SELECT AUTHOR_NAME FROM BOOK WHERE PAGES_NUMBER>200 AND GENRE = 'novel');

--***3.6. Заявка, която извежда името на най-четения автор (чиито книги са заемани най-много пъти) и колко пъти са заемани книгите му.
SELECT *
FROM (SELECT AUTHOR_NAME, COUNT(*) AS TIMES_READ
	  FROM BORROWING_BOOK
	  GROUP BY AUTHOR_NAME) AS T
WHERE TIMES_READ = (SELECT TOP 1 COUNT(*) AS TIMES_READ
				    FROM BORROWING_BOOK
	                GROUP BY AUTHOR_NAME
					ORDER BY TIMES_READ DESC);

--3.7. Заявка, която за всяка книга, която все още не е върната и срокът за връщане е изтекъл, извежда ID на книга, ЕГН, дни на закъснение, име на читател.
SELECT T.*, NAME
FROM ((SELECT BOOK_ID, MEMBER_EGN, DATEDIFF(DAY, DUE_DATE, GETDATE()) AS DELAY
	   FROM BORROWING
	   WHERE RETURN_DATE IS NULL AND GETDATE() > DUE_DATE) T JOIN MEMBER ON T.MEMBER_EGN = MEMBER.EGN)
ORDER BY MEMBER.EGN;

--3.8. -- Заявка, която извежда заглавието, автора, годината, издателството и броя копия от всяка книга в намаляващ ред.
SELECT TITLE, AUTHOR_NAME, YEAR, PUBLISHER_NAME, COPIES
FROM
(SELECT ISBN, COUNT(*) AS COPIES
FROM BOOKID
GROUP BY ISBN) AS T JOIN BOOK ON BOOK.ISBN = T.ISBN
ORDER BY COPIES DESC;

--4.join--

--4.1. Заявка, която извежда имената на читателите, които не са върнали книга и са просрочили датата ѝ за връщане.
SELECT DISTINCT NAME
FROM BORROWING JOIN MEMBER ON BORROWING.MEMBER_EGN = MEMBER.EGN
WHERE RETURN_DATE IS NULL AND GETDATE() > DUE_DATE;

--4.2. Заявка, която извежда името на издателствата, адресите, заглавие и жанра на последно публикуваните книги (за последната година, в която е публикувано).
SELECT PUBLISHER.NAME, PUBLISHER.ADDRESS, BOOK.TITLE, BOOK.GENRE
FROM PUBLISHER
JOIN BOOK ON PUBLISHER.NAME = BOOK.PUBLISHER_NAME
WHERE BOOK.TITLE IN (SELECT TITLE FROM BOOK WHERE YEAR IN (SELECT MAX(YEAR) FROM BOOK));

--4.3. Заявка, която извежда имената на издателствата, от които не е взимана нито 1 книга, ако има такива. --nishto ne izvejda
SELECT PUBLISHER_NAME
FROM BOOK
JOIN BOOKID ON BOOK.ISBN=BOOKID.ISBN
WHERE BOOKID.ID  NOT IN (SELECT BOOK_ID FROM BORROWING);

SELECT DISTINCT PUBLISHER_NAME
FROM BOOK
EXCEPT
SELECT DISTINCT PUBLISHER_NAME
FROM BOOK
JOIN BOOKID ON BOOK.ISBN=BOOKID.ISBN
WHERE BOOKID.ID IN (SELECT BOOK_ID FROM BORROWING);

--4.4. Заявка, която извежда името на издателството, телефонния номер, заглавията на книгите, произведени от това издателство, подредени по име на издателство.
SELECT PUBLISHER.NAME,PUBLISHER.PHONE_NUMBER, BOOK.TITLE
FROM PUBLISHER
JOIN BOOK ON PUBLISHER.NAME=BOOK.PUBLISHER_NAME
ORDER BY PUBLISHER.NAME;

--4.5. Заявка, която извежда всички автори и техните националности, които пишат книги в жанровете 'mystery' и 'romance' едновременно, ако има такива.
SELECT DISTINCT AUTHOR.NAME,AUTHOR.NATIONALITY
FROM AUTHOR
JOIN BOOK BOOK1 ON BOOK1.AUTHOR_NAME=AUTHOR.NAME
JOIN BOOK BOOK2 ON BOOK2.AUTHOR_NAME=AUTHOR.NAME
WHERE BOOK1.GENRE = 'mystery' AND BOOK2.GENRE = 'romance' AND BOOK1.AUTHOR_NAME=BOOK2.AUTHOR_NAME; 

--4.6. Заявка, която извежда средния брой страници на книгите в библиотеката, издадени от 'Bard'.
SELECT AVG(PAGES_NUMBER) AS AVERAGE_PAGES_NUM
FROM BOOK
JOIN BOOKID ON BOOKID.ISBN=BOOK.ISBN
WHERE PUBLISHER_NAME = 'Bard';

--4.7. Заявка, която извежда данните за библиотекарите, които не са членове.
SELECT LIBRARIAN.*
FROM LIBRARIAN LEFT JOIN MEMBER ON LIBRARIAN.EGN = MEMBER.EGN
WHERE MEMBER.EGN IS NULL;

--4.8. Заявка, която за всяко издателство, от което имаме книга, извежда жанра на книгите, които то последно е издало, както и името и адреса му.
SELECT DISTINCT PUBLISHER.NAME, PUBLISHER.ADDRESS, GENRE
FROM BOOK JOIN (SELECT PUBLISHER_NAME, MAX(BOOK.YEAR) AS MAX_YEAR
				FROM BOOK
				GROUP BY PUBLISHER_NAME) T ON BOOK.PUBLISHER_NAME = T.PUBLISHER_NAME AND BOOK.YEAR = T.MAX_YEAR JOIN PUBLISHER ON PUBLISHER.NAME = T.PUBLISHER_NAME;

--5.group by--

--5.1. Заявка, която за всeки читател, който е взимал поне 1 книга, извежда името му и средното време за което той връща книгите.
SELECT NAME, AVG_RETURN_TIME
FROM (SELECT MEMBER_EGN, AVG(DATEDIFF(DAY, BORROW_DATE, RETURN_DATE)) AS AVG_RETURN_TIME
	  FROM BORROWING
	  WHERE RETURN_DATE IS NOT NULL
	  GROUP BY MEMBER_EGN) T 
JOIN MEMBER ON T.MEMBER_EGN = MEMBER.EGN;

--5.2.Заявка, която извежда средния брой страници на книгите в библиотеката за всяко издателство и неговото име.
SELECT PUBLISHER_NAME,AVG(PAGES_NUMBER) AS AVERAGE_PAGES_NUM
FROM BOOK
JOIN BOOKID ON BOOKID.ISBN=BOOK.ISBN
GROUP BY PUBLISHER_NAME;

--5.3. Заявка, която извежда издателите, които са издали поне три книги в различен жанр, и броя на тези жанрове. 
SELECT PUBLISHER_NAME, COUNT(DISTINCT GENRE) AS NUM_GENRES
FROM BOOK
GROUP BY PUBLISHER_NAME
HAVING COUNT(DISTINCT GENRE) >= 3;

--5.4. Заявка, която извежда за всеки читател първата и последната дата, в която е заемал книга.
SELECT MEMBER.NAME,MEMBER.EGN, MIN(BORROW_DATE) AS FIRST_BORROW_DATE, MAX(BORROW_DATE) AS LAST_BORROW_DATE
FROM MEMBER
JOIN BORROWING ON BORROWING.MEMBER_EGN= MEMBER.EGN
GROUP BY MEMBER.NAME,MEMBER.EGN;

--5.5. Заявка, която извежда имената и егн на първите 7 читатели, които са заемали най-много книги някога.
SELECT TOP 7 NAME, EGN, BORROWED_BOOKS_EVER
FROM MEMBER JOIN (SELECT MEMBER_EGN, COUNT(*) AS BORROWED_BOOKS_EVER
				  FROM BORROWING
				  GROUP BY BORROWING.MEMBER_EGN) T ON MEMBER.EGN = T.MEMBER_EGN
ORDER BY BORROWED_BOOKS_EVER DESC;

--5.6. Заявка, която показва най-скорошните година и месец, в които има най-много взети книги.
SELECT TOP 1 *, COUNT(*) AS BOOKS_BORROWED
FROM (SELECT CONCAT(YEAR(BORROW_DATE), '-', MONTH(BORROW_DATE)) AS YEAR_MONTH FROM BORROWING) AS T
GROUP BY T.YEAR_MONTH
ORDER BY COUNT(*) DESC, T.YEAR_MONTH DESC;

--5.7. Заявка, която извежда автора, който е написали най-много страници (общо за всички книги) за всяко издателство.
SELECT S.AUTHOR_NAME, S.PUBLISHER_NAME, SUM_PAGES
FROM (SELECT AUTHOR_NAME, PUBLISHER_NAME, SUM(PAGES_NUMBER) AS SUM_PAGES
		FROM BOOK 
		GROUP BY AUTHOR_NAME, PUBLISHER_NAME) S
WHERE S.SUM_PAGES IN (SELECT MAX(SUM_PAGES) FROM (SELECT AUTHOR_NAME, PUBLISHER_NAME, SUM(PAGES_NUMBER) AS SUM_PAGES
												 FROM BOOK 
												 GROUP BY AUTHOR_NAME, PUBLISHER_NAME) S1 GROUP BY  S1.PUBLISHER_NAME)


--***5.8. Заявка, която извежда книгите, които са най-четени за всеки автор.
SELECT U.* FROM (SELECT AUTHOR_NAME, MAX(TIMES_READ) AS MAX_TIMES_READ
		 FROM (SELECT AUTHOR_NAME, TITLE, COUNT(*) AS TIMES_READ
		 	  FROM (SELECT BORROWING_BOOK.AUTHOR_NAME, BORROWING_BOOK.TITLE FROM BORROWING_BOOK) AS T
		 	  GROUP BY AUTHOR_NAME, TITLE) AS T
		 GROUP BY AUTHOR_NAME) AS T JOIN (SELECT AUTHOR_NAME, TITLE, COUNT(*) AS TIMES_READ
		 								  FROM (SELECT BORROWING_BOOK.AUTHOR_NAME, BORROWING_BOOK.TITLE FROM BORROWING_BOOK) AS T
		 								  GROUP BY AUTHOR_NAME, TITLE) AS U ON T.AUTHOR_NAME = U.AUTHOR_NAME AND T.MAX_TIMES_READ = U.TIMES_READ
ORDER BY U.AUTHOR_NAME;

--***5.9. Заявка, която извежда издателството, чиято книга е взимана най-често и нейното заглавие.
SELECT PUBLISHER_NAME, TITLE, T.TIMES_READ FROM (
SELECT * FROM ISBN_TIMES_READ
WHERE TIMES_READ = (SELECT MAX(TIMES_READ)
			        FROM ISBN_TIMES_READ)) AS T JOIN BOOK ON T.ISBN = BOOK.ISBN;

--5.10. Заявка, която извежда имената читателите, които за просрочили датата за връщане поне два пъти и броя на тези нарушения.
SELECT NAME, COUNT(*) AS DELAYS
FROM BORROWING JOIN MEMBER ON BORROWING.MEMBER_EGN = MEMBER.EGN
WHERE RETURN_DATE > DUE_DATE OR (RETURN_DATE IS NULL AND GETDATE() > DUE_DATE)
GROUP BY EGN, NAME
HAVING COUNT(*) > 1;

--5.11 Заявка, която извежда общия брой книги, които са взети в момента. 
SELECT COUNT(*)
FROM BORROWING
WHERE RETURN_DATE IS NULL;

-- Тази заявка изтрива данните за тези читатели, които имат 3 или повече нарушения.
DELETE FROM MEMBER
WHERE EGN IN (SELECT MEMBER_EGN FROM BORROWING
			  WHERE RETURN_DATE > DUE_DATE OR (RETURN_DATE IS NULL AND GETDATE() > DUE_DATE)
			  GROUP BY MEMBER_EGN
			  HAVING COUNT(*) >= 3);
