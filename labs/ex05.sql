use pc;

--1--
select avg(speed) as AvgSpeed
from pc;

--2--
select p.maker, avg(l.screen) as AvgScreen
from product p
join laptop l on l.model = p.model
group by p.maker;

--3--
select avg(speed) as AvgSpeed 
from laptop 
where price>1000;

--4--
select p.maker,avg(pc.price) as AvgScreen
from product p
join pc on pc.model = p.model
where p.maker = 'A'
group by p.maker;

--5--
select p.maker,avg(t.price) as AvgScreen
from (select model,price from pc union all select model, price from laptop) t
join product p on t.model = p.model
where p.maker = 'B'
group by p.maker;

--6--
select speed, avg(price) as AvgPrice
from pc
group by speed;

--7--
select p.maker, count(pc.model) as number_of_pc
from product p
join pc on pc.model = p.model
group by maker
having count(pc.model) >=3;

--8--
select top 1 p.maker, max(pc.price)
from product p
join pc on pc.model = p.model
group by maker;

--9--
select speed, avg(price) as AvgPrice
from pc
group by speed
having speed>800;

--10--
select p.maker,avg(pc.hd) as AvgHDD
from pc
join product p on pc.model = p.model
where p.maker in (select distinct p1.maker from product p1 
join printer pr on pr.model = p1.model)
group by p.maker;

use ships;

--1--
SELECT COUNT(DISTINCT S.CLASS) AS NO_Classes
FROM SHIPS S
JOIN OUTCOMES O ON O.SHIP = S.NAME;

--1.2--
SELECT COUNT(DISTINCT CLASS) AS NO_Classes
FROM CLASSES 
WHERE TYPE = 'bb';

--2--
SELECT DISTINCT C.CLASS, AVG(C.NUMGUNS) AS avgGuns
FROM CLASSES C
WHERE TYPE = 'bb'
GROUP BY C.CLASS;

--3--
SELECT AVG(C.NUMGUNS) AS avgGuns
FROM CLASSES C
WHERE TYPE = 'bb';

--4--
SELECT CLASS, MIN(LAUNCHED) AS FirstYear, MAX(LAUNCHED) AS LastYear
FROM SHIPS
GROUP BY CLASS;

--5--
SELECT S.CLASS, COUNT(O.RESULT) AS No_Sunk
FROM SHIPS S
JOIN OUTCOMES O ON O.SHIP = S.NAME
WHERE O.RESULT = 'sunk'
GROUP BY CLASS;

--6--
SELECT S.CLASS, COUNT(O.RESULT) AS No_Sunk
FROM SHIPS S
JOIN OUTCOMES O ON O.SHIP = S.NAME
WHERE O.RESULT = 'sunk' AND CLASS IN (SELECT C.CLASS FROM CLASSES C 
JOIN SHIPS S ON S.CLASS = C.CLASS GROUP BY C.CLASS HAVING COUNT(C.CLASS)>=2)
GROUP BY CLASS;

--7--
SELECT C.COUNTRY, AVG(C.BORE) AS avg_bore
FROM CLASSES C
JOIN SHIPS S ON S.CLASS= C.CLASS
GROUP BY C.COUNTRY;

