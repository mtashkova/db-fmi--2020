USE movies;

--1--
SELECT MS.NAME
FROM  MOVIESTAR MS
WHERE MS.NAME IN (SELECT NAME FROM MOVIEEXEC WHERE GENDER = 'F' AND NETWORTH > 10000000);

--2--
SELECT MS.NAME
FROM  MOVIESTAR MS
WHERE MS.NAME NOT IN (SELECT NAME FROM MOVIEEXEC);

--3--
SELECT TITLE
FROM MOVIE
WHERE LENGTH>ANY(SELECT LENGTH FROM MOVIE WHERE TITLE LIKE 'Star Wars');

--4--
SELECT M.TITLE, ME.NAME
FROM MOVIE M
JOIN MOVIEEXEC ME ON M.PRODUCERC# = ME.CERT#
WHERE ME.NETWORTH > (SELECT NETWORTH FROM MOVIEEXEC WHERE NAME LIKE 'Merv Griffin');

USE pc;

SELECT *
FROM printer;
SELECT*
FROM product;

--1--
select maker
from product
where type like 'PC' and  model in (select model from pc where speed >500);

--2--
select code, model, price
from printer
where price like (select max(price) from printer);

--3--
select *
from laptop
where speed < all(select speed from pc);

--4--
select top 1 * from
(select pc.model,price
from pc
where price like (select max(price) from pc)
union
select model,price
from laptop
where price like (select max(price) from laptop)
union
select model,price
from printer
where price like (select max(price) from printer)) as p
order by p.price desc;


--5-- 
select top 1 p.maker
from product p
join printer pr on p.model= pr.model
where pr.color = 'y'
order by price;

--6--
select p.maker
from pc
join product p on p.model = pc.model
where ram = (select min(ram) from pc)
and speed =(select max(speed) from pc where ram =(select min(ram) from pc));

USE ships;

--1--
select distinct country
from classes
where numguns = (select max(numguns) from classes);

--2--
select distinct c.class
from classes c
join ships on ships.class = c.class
join outcomes o on o.ship = ships.name
where o.result = any(select result from outcomes where result = 'sunk');

--3--
select ships.name, ships.class
from ships 
join classes c on c.class = ships.class
where bore = 16;

--4--
select o.battle
from outcomes o
join ships s on o.ship = s.name
where class = 'Kongo';

--5--

