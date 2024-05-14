create database FoodService;
use FoodService;

Create table OpeningDate (
opening_id int primary key auto_increment not null,
days enum('weekdays','weekend'),
opening_time datetime,
closing_time datetime
);

create table Restaurant(
resId int primary key auto_increment not null,
resName varchar(150),
res_address varchar(250),
res_phone varchar(20),
res_mail varchar(150),
res_image binary,
res_isActive bool,

opening_id int, 
constraint fk_opening
foreign key (opening_id)
references OpeningDate(opening_id)
);

Create table Workers (
workerId int primary key auto_increment not null,
FirstName varchar(50),
LastName varchar(50),
Address varchar(60),
Phone varchar(50),
Email varchar(100),
JobTitle varchar(100),
Salary int,
ReportsTo int,

resId int,
constraint fk_res
foreign key(resId) 
references Restaurant(resId)
);


Create table Customers (
customerId int primary key auto_increment not null,
FirstName varchar(50),
LastName varchar(50),
Address varchar(100),
Phone varchar(60),
Email varchar(100),
Balance int, 
Card varchar(300),
Promocode varchar(100)
);

create table Menu(
menuId int primary key auto_increment NOT NULL,
menu_name varchar(150),

resId int,
constraint fk_rest
foreign key (resId) 
references Restaurant(resId ) 
);

Create table MenuGroup(
groupId int primary key auto_increment not null,
groupName varchar(50),
groupImage binary,
groupSize enum('samll','medium','large'),

menuId int not null,
constraint fk_menu
foreign key (menuId) 
references Menu(menuId)
);

Create table MenuItem (
itemId int primary key auto_increment not null,
itemName varchar(50),
itemImage binary,
itemDescription varchar(100),
price double ,
depoCount int,
itemType enum('main', 'extra'),
itemSize enum('small', 'medium', 'large'),

groupId int not null,
constraint fk_menuGroup
foreign key (groupId) 
references MenuGroup(groupId)
);

Create table Rating (
ratingId int primary key auto_increment not null,
score int,
date_recorded date,

itemId int,
constraint fk_menuItem
foreign key(itemId) 
references MenuItem(itemId), 

customerId int,
constraint fk_customer
foreign key(customerId)
references Customers(customerId)
);

create table Delivery(
deliveryId int primary key auto_increment not null,
vehicleType varchar(150),
supportServiceName varchar(150),

workerId int, 
constraint fk_work
foreign key(workerId)
references Workers(workerId)
);

create table Orders(
orderId int primary key auto_increment not null,
ordered_date datetime,
takenOver_date datetime,
order_status enum('draft', 'ordered', 'preparing', 
'checking', 'prepared', 'delivering', 'taken over', 'canceled'),
address varchar(200),

customerId int,
constraint fk_cust
foreign key(customerId)
references Customers(customerId),

workerId int, 
constraint fk_worker
foreign key(workerId)
references Workers(workerId), 

deliveryId int,
constraint fk_delivery
foreign key(deliveryId)
references Delivery(deliveryId)
);

create table Order_Item(
oItemId int primary key auto_increment not null,
quantity int,

orderId int,
constraint fk_order
foreign key (orderId)
references Orders(orderId),

itemId int, 
constraint fk_item
foreign key (itemId)
references MenuItem(itemId)
);

create table Coupon(
couponId int primary key auto_increment not null,
coupon_Name varchar(30),
coupon_Code varchar(30),
discount double,
maxUse int,

resId int,
constraint fk_restaurantId
foreign key(resId)
references Restaurant(resId)
);

create table Payment(
paymentId int primary key auto_increment not null,
totalAmount int,
paymentType varchar(30),
payment_date date,

orderId int,
constraint fk_orders
foreign key(orderId)
references Orders(orderId),

couponId int,
constraint fk_coupon
foreign key(couponId)
references Coupon(couponId)
);


DELIMITER $$
create procedure GetCountbyFood( 
in foodId INT,
out orderCount INT 
)
BEGIN
declare x decimal default 0;
    select count(oItemId) into x  from Order_Item
    where itemId= foodId;
    set orderCount=x;
END $$ 
DELIMITER ;

call GetCountbyFood(0,@orderCount);
select @orderCount;


DELIMITER $$
create procedure GetOrderbyName( 
in foodName varchar(200), 
out orderStatus varchar(200))

Begin  
declare iname varchar(200);
		select itemName 
        into iname from MenuItem 
        inner join Order_Item using(itemId)
        inner join Orders using(orderId);
        
	if foodName=iname then 
    set orderStatus='ordered';
    else 
    set orderStatus='draft';
    end if;
END $$ 
DELIMITER ;

call GetOrderbyName(0, @orderStatus);
select @orderStatus;


DELIMITER $$
create procedure GetCountbyUser( 
in customer INT,
out orderCount INT 
)
BEGIN
declare countO int default 0;
	select count(orderId) into countO from Orders
	inner join Customers using(customerId)
    
    where customerId=customer;
    set orderCount=countO;
END $$ 
DELIMITER ;

call GetCountbyUser(0,@orderCount);
select @orderCount;

DELIMITER $$
Create procedure GetsWorkerbyFood(
IN foodName varchar(100),
OUT workerName varchar(100))
BEGIN
declare worker varchar(200);
	  select concat(w.FirstName, w.LastName) into worker from Workers w
	  inner join Orders using(workerId)
      inner join Order_item using(orderId)
      inner join MenuItem m using(itemId)
where itemName=foodName;
set workerName=worker;
END $$
 DELIMITER ;

call GetsWorkerbyFood(1,@workerName);
select @workerName;


DELIMITER $$
create procedure GetTotalGainbyDay(
in Days varchar(150),
out Gain int
)
BEGIN
declare TotalGain decimal default 0;
   select count(totalAmount) into TotalGain from Payment
   where payment_date=Days;
   set Gain=TotalGain;
END $$
DELIMITER ;

call GetTotalGainbyDay('2002-12-19', @Gain);
select @Gain;


DELIMITER $$
Create procedure GetsDeliveryService(
IN orderName int,
OUT DeliveryService int
)
BEGIN
declare service int;
	  select deliveryId into service from Delivery
	  inner join Orders using(deliveryId)
where orderId=orderName;
set DeliveryService=service;
END $$
 DELIMITER ;

call GetsDeliveryService(1,@DeliveryService);
select @DeliveryService;


DELIMITER $$
Create procedure GetRating(
IN MenuName int,
OUT rating int
)
BEGIN
declare scoreR int;
	  select score into scoreR from Rating
	  inner join MenuItem using(itemId)
where itemId=MenuName;
set rating=scoreR;
END $$
 DELIMITER ;

call GetRating(0, @rating);
select @rating;

-- food adi onun cancell olunma sayi--
DELIMITER $$
create procedure GetCancellbyFood(
in foodName varchar(100),
out canceledCount int
)
BEGIN
declare counts int;
	select count(orderId) into counts from Orders
    inner join Order_Item using(orderId)
    inner join MenuItem using(itemId)
where order_status='canceled' and foodName=itemName;
set canceledCount=counts;
END$$
DELIMITER ;

call GetCancellbyFood(0, @canceledCount);
select @canceledCount;

-- customer daxil edin payment zamani istifade olunnan kupon sayi--
DELIMITER $$
create procedure GetCouponbyCustomer(
in customerName varchar(100),
out couponCount int
)
BEGIN 
declare counts int;
	select count(couponId) into counts from Coupon
    inner join Payment using(couponId)
    inner join Orders using(orderId)
    inner join Customers c using(customerId)
where concat(c.FirstName, ' ', c.LastName)=customername;
set couponCount= counts;
END$$
DELIMITER ;

call GetCouponbyCustomer(0, @couponCount);
select @couponCount;


CREATE VIEW ManagerWorker AS 
select ifnull(Concat(m.FirstName, ' ',  m.LastName), 'Top Manager')
 as Manager,
 Concat(w.FirstName, ' ', w.LastName) as Worker
 from Workers m
 left join Workers w on 
 m.workerId=w.ReportsTo 
 order by manager desc;
 
SELECT * FROM ManagerWorker;

CREATE TABLE customer_change (
id INT AUTO_INCREMENT PRIMARY KEY,
customerId int not null,
FirstName varchar(50),
LastName varchar(50),
changeDate DATETIME DEFAULT NULL,
action VARCHAR(50) DEFAULT NULL
);

DELIMITER $$
CREATE TRIGGER after_customer_update 
    after UPDATE ON Customers
    FOR EACH ROW 
BEGIN
INSERT INTO customer_change
SET action = 'update',
	 customerId=OLD.customerId,
     FirstName = OLD.FirstName,
     LastName = OLD.LastName,
     changeDate = NOW();
END$$
DELIMITER ;

insert into Customers(FirstName, LastName)
values('Ruhan', 'Musayev'),
('Kemale', 'Agayev'),
('Ayten', 'Babayeva');

update Customers
set FirstName='Nezaket' 
where customerId=2;

select* from customer_change;


CREATE TABLE WorkerArchives (
    id INT PRIMARY KEY AUTO_INCREMENT,
    workerId INT,
    FirstName varchar(100),
    LastName varchar(100),
    Salary int not null default 0, 
	deletedAt TIMESTAMP DEFAULT NOW()
);

insert into Workers(FirstName, LastName, Salary)
values('Nuray', 'Qasimova', 1000),
('Leman', 'Hesenli', 800),
('Elgiz', 'Bayramov', 900);

DELIMITER $$
create trigger before_worker_delete
before delete on Workers for each row
begin 
	insert into WorkerArchives(workerId, FirstName, LastName, Salary)
	values(old.workerId, old.FirstName, old.LastName, old.Salary);
END$$
DELIMITER ;

delete from Workers
where workerId=2;

select * from WorkerArchives;


CREATE  VIEW customerOrders AS
SELECT concat(c.FirstName, ' ', c.LastName) as 'Customer', 
o.orderId as'Order', sum(p.totalAmount) as 'Total'
from Customers c
INNER JOIN Orders o USING  (customerId)
INNER JOIN Payment p USING (orderId)
GROUP BY orderId;

select * from customerOrders;

Create VIEW workerCustomer AS
SELECT 
Concat(w.FirstName, ' ', w.LastName) as 'Worker Name',
Concat(c.FirstName, ' ', c.LastName) as 'Customer Name'
FROM  Customers c
INNER JOIN Orders USING(customerId)
right join Workers w using(workerId)
GROUP BY workerId;

select * from workerCustomer;


CREATE  VIEW customerOrder AS
SELECT 
concat(FirstName,LastName),
    oItemId,
    sum(quantity*price) as total
FROM
    Order_Item
INNER JOIN Orders USING  (orderId)
INNER JOIN MenuItem USING (itemId)
INNER JOIN Customers USING (customerId)

GROUP BY oItemId;
select * from customerOrders;

CREATE VIEW WorkerRestaurant AS 
select concat(w.FirstName, w.LastName) as worker, 
r.resName as restaurant
from Workers w, Restaurant r
where r.resId=2 and w.Salary>1500
order by worker asc;

SELECT * FROM WorkerRestaurant;

CREATE INDEX jobTitle ON Workers(jobTitle);
EXPLAIN SELECT 
    workerId, 
    FirstName,
    LastName    
FROM
    Workers
WHERE
    jobTitle = 'Delivery';
    
    
CREATE INDEX CustomersName ON Customers (FirstName(50));
EXPLAIN SELECT 
    FirsName, 
    LastName
FROM
    Customers
WHERE
    FirstName = 'Ruhan';
    
    
SHOW INDEXES FROM Customers;


select count(*) from Customers c  -- 1 --
inner join Rating r using(customerId)
inner join Orders o using(customerId)
inner join Payment p using(orderId)
where r.score=10 and p.couponId is not null;

select totalAmount from Payment    -- 2--
inner join Orders using (orderId)
where order_status = "canceled"
and ordered_date>= day(current_date()) - 7;  

insert into Workers(FirstName, LastName)
values('Rahim', 'Hasanli');

insert into Workers(FirstName, LastName, ReportsTo)
values('Ruhan', 'Musayev', 1),
('Kemale', 'Agayev', 1); 

select ifnull(concat(w.FirstName, w.LastName),    -- 3--
'Top Manager') as 'Manager',
Concat(e.FirstName, e.LastName) as 'Worker'
from Workers e
left join Workers w on w.workerId=e.ReportsTo
order by manager desc;

select FirstName, ordered_date, orderId  from Customers  -- 4--
inner join Orders using (customerId)
inner join Payment using (orderId)
order by totalAmount desc limit 10;

select orderId from Orders  -- 5--
inner join Order_Item using(orderId)
inner join MenuItem using(itemId)
where order_status = "preparing" and price>50;

select Concat(w.FirstName, w.LastName) as 'Worker Name', -- 6--
Concat(c.FirstName, c.LastName) as 'Customer Name' from Customers c 
inner join Orders using(customerId)
right join Workers w using(workerId);

select concat(w.FirstName, w.LastName) as worker, -- 7--
r.resName as restaurant
from Workers w, Restaurant r
where r.resId=2 and w.Salary>1500
order by worker asc;

select i.itemName, i.depoCount, r.resId, r.resName from MenuItem i -- 8--
inner join MenuGroup g using(groupId)
inner join Menu m using(menuId)
inner join Restaurant r using(resId)
group by resId; 

select m.itemName, m.price, o.quantity, m.itemId,   -- 10--
count(o.oItemId) as count from MenuItem m
inner join Order_Item o using(itemId)
inner join Orders using(orderId)
where order_status='taken over'
group by itemId;

select m.itemName, m.depoCount, o.ordered_date from MenuItem m -- 11--
inner join Order_Item using(itemId)
inner join Orders o using(orderId)
where depoCount=0;

select concat(w.FirstName, w.LastName) as 'Delivery Worker',	-- 12--
 o.orderId as'Order' from Workers w  
inner join Delivery d using(workerId)
inner join Orders o using(deliveryId);

select FirstName from Customers  -- 13--
inner join Orders using (customerId)
inner join Payment using(orderId)
inner join Coupon using (couponId)
where maxUse=0;