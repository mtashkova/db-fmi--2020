
--1--
CREATE TABLE Product 
( maker  char(4),
  model char(1),
  type varchar(7)
);

--2--
CREATE TABLE Printer
( code  int,
  model char(4),
  price decimal
);

--3--
INSERT INTO Product VALUES ('DVDF', 'C', 'laptop');
INSERT INTO Printer VALUES (56, 'city', 105.10);

--4--
ALTER TABLE printer ADD type VARCHAR(6) CHECK (type IN('laser', 'matrix', 'jet'));
ALTER TABLE printer ADD color VARCHAR(1) DEFAULT 'n' CHECK (color IN('n', 'y'));;

--5--
ALTER TABLE Printer DROP price;

--6--
DROP TABLE Printer;
DROP TABLE Product;

CREATE DATABASE Facebook
GO
USE Facebook;

CREATE TABLE Users 
( id INT CONSTRAINT id_pk PRIMARY KEY,
email VARCHAR(20),
password VARCHAR(20),
date DATE
);

CREATE TABLE Friends 
(user1 INT,
user2 INT
);

CREATE TABLE Walls 
( usernum INT,
  ownernum INT,
  description TEXT,
  date DATE
);

CREATE TABLE Groups
( id INT UNIQUE,
name VARCHAR(20),
desctiption VARCHAR(20) DEFAULT '',
);

CREATE TABLE GroupMembers 
( groupnum INT,
  usernum INT,
);

INSERT INTO Friends VALUES(1, 2);
INSERT INTO GroupMembers VALUES(1, 3);
INSERT INTO Groups (id, name) VALUES(5, 'group1');
INSERT INTO Users VALUES (1, 'no@google.com', '123123', '12-04-2019');
INSERT INTO Walls VALUES (1, 2, 'sup', '12-04-2019');

select *
from walls;
