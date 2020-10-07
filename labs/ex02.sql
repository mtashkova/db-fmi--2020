USE movies;

--1--
select s.STARNAME AS name 
from starsin s 
JOIN MOVIESTAR m ON s.STARNAME = m.NAME
WHERE m.GENDER = 'M' and s.MOVIETITLE = 'The Usual Suspects';

--2--
select s.STARNAME
from STARSIN s
JOIN MOVIE m ON (s.MOVIETITLE=m.TITLE and s.MOVIEYEAR = m.YEAR)
WHERE m.YEAR = '1995' and m.STUDIONAME ='MGM';

--3--
select DISTINCT m.NAME
FROM MOVIEEXEC m
JOIN MOVIE movie ON movie.[PRODUCERC#] = m.[CERT#]
WHERE movie.STUDIONAME = 'MGM';

--4--
SELECT M1.TITLE
FROM MOVIE M1
WHERE (select length from MOVIE WHERE TITLE = 'Star Wars' ) < M1.LENGTH;

--5--
select NAME 
from MOVIEEXEC
WHERE (SELECT NETWORTH FROM MOVIEEXEC WHERE NAME='Stephen Spielberg') < NETWORTH;

--6--
SELECT m.TITLE
FROM MOVIE m
JOIN MOVIEEXEC me ON me.CERT# = m.PRODUCERC#
WHERE (SELECT NETWORTH FROM MOVIEEXEC WHERE NAME ='Stephen Spielberg') < me.NETWORTH;

USE pc;

--1--
select p.maker, l.speed
from product p
join laptop l on l.model = p.model
where l.hd >=9;

--2--
select l.model, l.price
from laptop l
join product p on l.model = p.model 
where p.maker ='B'
UNION
select pc.model,pc.price
from pc
join product p on pc.model = p.model
where p.maker ='B'
UNION
select pr.model,pr.price
from printer pr
join product p on pr.model = p.model
where p.maker ='B';

--3--
select maker
from product
where type = 'Laptop'
EXCEPT
select maker
from product 
where type = 'PC';

--4--
select distinct p1.hd 
from pc p1, pc p2 
where p1.code!=p2.code and p1.hd = p2.hd;

--5--
select distinct p1.model, p2.model
from pc p1, pc p2
where p1.model<p2.model and p1.code!=p2.code and p1.speed = p2.speed and p1.ram = p2.ram;

--6--
select distinct pr.maker
from product pr
join pc p1  on p1.model = pr.model
where p1.speed>=400
group by maker
having count(maker)>1;


USE ships;

--1--
select S.NAME
from SHIPS S
JOIN CLASSES C ON S.CLASS = C.CLASS
WHERE C.DISPLACEMENT>50000;

--2--
SELECT S.NAME, C.DISPLACEMENT, C.NUMGUNS
FROM SHIPS S
JOIN CLASSES C ON C.CLASS = S.CLASS
JOIN OUTCOMES O ON S.NAME = O.SHIP
WHERE O.BATTLE = 'Guadalcanal';

--3--

SELECT C1.COUNTRY
FROM CLASSES C1, CLASSES C2
WHERE C1.TYPE='bc' AND C2.TYPE ='bb' and C1.COUNTRY=C2.COUNTRY;

--4--
SELECT O1.SHIP
FROM OUTCOMES O1, OUTCOMES O2, BATTLES B1, BATTLES B2
WHERE O1.RESULT= 'damaged' AND O2.RESULT ='ok' AND O1.SHIP = O2.SHIP AND
B1.NAME = O1.BATTLE AND B2.NAME = O2.BATTLE AND B1.DATE<B2.DATE;

SELECT* 
FROM BATTLES
ORDER BY DATE;
SELECT* 
FROM OUTCOMES;





