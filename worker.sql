
use worktime

-- Удаление таблиц
/* 
ALTER TABLE time_control
   DROP CONSTRAINT time_control_to_worker 
DROP TABLE worker;
DROP TABLE time_control;
DROP TABLE department;
DROP TABLE task;
*/

-- Создание и связывание таблиц 

CREATE TABLE department(
id integer identity(1,1) primary key,
name nvarchar(MAX),
address nvarchar(MAX),
boss nvarchar(MAX),
dep_code integer
)

CREATE TABLE task(
id integer identity(1,1) primary key,
name nvarchar(MAX),
work_shift nvarchar(MAX),
task_code integer,
work_hours integer,
difficulty nvarchar(MAX),
)

CREATE TABLE time_control(
id integer identity(1,1) primary key,
date date,
time_in time,
time_out time,
worker_id integer,
task_id integer,
total_time float,
CONSTRAINT FK_time_control_to_task FOREIGN KEY (task_id)  REFERENCES task (id) ON DELETE CASCADE,
)


CREATE TABLE worker(
id integer identity(1,1) primary key,
fio nvarchar(MAX),
dep_id integer,
task_id integer,
CONSTRAINT FK_worker_to_department FOREIGN KEY (dep_id)  REFERENCES department (id) ON DELETE CASCADE,
CONSTRAINT FK_worker_to_task FOREIGN KEY (task_id)  REFERENCES task (id) ON DELETE CASCADE,
)

ALTER TABLE time_control
   ADD CONSTRAINT time_control_to_worker FOREIGN KEY (worker_id)
      REFERENCES worker (id);

-- Триггер для таблицы time_control, который автоматически считает количество часов проведенное на работе

CREATE TRIGGER total_time_count ON time_control
AFTER INSERT, UPDATE
AS UPDATE time_control
Set total_time = ROUND(DATEDIFF(minute, time_in, time_out)/60.0,2)
WHERE id = (SELECT Id FROM inserted);


 -- Запрос а. Отобраэжает всех работников их работу и отдел, если их работа больше или равна 256, определяет ее как трудоемкую
 Select fio, task.name 'task', task.work_hours, task.difficulty, department.name 'department', "Трудоемкость" =
 CASE 
	When task.work_hours >=256 THEN 'трудоемкая'
	else 'Не трудоемкая'
END
 FROM department 
 INNER JOIN worker ON department.id = worker.dep_id
  INNER JOIN task ON worker.task_id = task.id;

 create function a()
 returns table 
 as 
return(
  Select fio, task.name 'task', task.work_hours, task.difficulty, department.name 'department', "Трудоемкость" =
 CASE 
	When task.work_hours >=256 THEN 'трудоемкая'
	else 'Не трудоемкая'
END
 FROM department 
 INNER JOIN worker ON department.id = worker.dep_id
  INNER JOIN task ON worker.task_id = task.id
 );

 select * from a()

  -- запрос b.Функция с отображением работников которые хоть раз работали больше 8 часов через многотабличный view 

   CREATE VIEW hardworking_workers1
            AS SELECT Distinct worker.fio, time_control.date, time_control.time_in, time_control.time_out, time_control.total_time
            FROM time_control 
 INNER JOIN worker ON time_control.worker_id= worker.id
            WHERE time_control.total_time >= '8'
			

create function view1(@t1 text)
 returns table 
 as 
return(
Select * from hardworking_workers1 Order By @t1
);
 
 -- запрос с.

 --с.1 Некоррелированные

SELECT * FROM task
WHERE work_hours > (SELECT AVG(work_hours) FROM task)

SELECT * from (Select * from time_control) as total

Select (Select Count(*) from task), name from task


--c.2 Кореллированные 

select *
  from task as t
  where 
    work_hours <= (select avg(work_hours)
                      from task
                      where t.id = id)

select fio,name,work_shift from worker outer apply (select * from  task where task.id = worker.task_id) as f


SELECT t.difficulty, t.name,
    (SELECT MAx(t2.total_time)
     FROM time_control as t2
     WHERE t.id = t2.task_id) AS "Максимально потрачено времени в день"
FROM task AS t;

SELECT t.difficulty, t.name, (SELECT MAx(t2.total_time) FROM time_control as t2 WHERE t.id = t2.task_id) AS "Максимально потрачено времени в день" FROM task AS t;


--запрос d. Многотабличгный запрос который группирует записи по фио и выводит количство рабочих дней, тех у кого суммарное проработанное время больше 10 часов

Select fio, count(*) as 'количество дней', total_time
From time_control 
Inner join worker ON time_control.worker_id= worker.id
Group by fio, total_time
Having SUM(total_time) > 10

create function d()
 returns table 
 as 
return(
Select fio, count(*) as 'количество дней', total_time
From time_control 
Inner join worker ON time_control.worker_id= worker.id
Group by fio, total_time
Having SUM(total_time) > 10
);

SELECT * from d()
--запрос e. Отображает работников 2 отделения у которых было время работы больше чем у всех сотрудников 2 отделения

SELECT Distinct fio
            FROM time_control
 INNER JOIN worker ON time_control.worker_id= worker.id
 Where total_time > ALL(Select total_time FROM time_control 
 INNER JOIN worker ON time_control.worker_id= worker.id
 Where dep_id ='1')
 
SELECT Distinct fio, total_time FROM time_control INNER JOIN worker ON time_control.worker_id= worker.id Where total_time > ALL(Select total_time FROM time_control INNER JOIN worker ON time_control.worker_id= worker.id Where dep_id ='1')


 -- создание индексов 

 CREATE NONCLUSTERED INDEX IX_time_control_worker_id
ON time_control (worker_id)


 CREATE NONCLUSTERED INDEX IX_time_control_task_id
ON time_control (task_id)

CREATE NONCLUSTERED INDEX IX_worker_dep_id
ON worker (dep_id)

CREATE NONCLUSTERED INDEX IX_worker_task_id
ON worker (task_id)

CREATE NONCLUSTERED INDEX IX_worker_task_id
ON worker (task_id)



CREATE NONCLUSTERED INDEX IX_time_control_total_time
ON time_control (total_time)

CREATE NONCLUSTERED INDEX IX_department_dep_code
ON department (dep_code)


--использование скалярных и векторных функций 

--Отображает время задания в минутах
Create function hours_to_min(@work_hours int)
returns int
AS 
BEGIN  
    DECLARE @min int;  
	Set @min = @work_hours * 60;
	RETURN @min;  
End;

SELECT name, worktime.dbo.hours_to_min(work_hours) as "В минутах"  from task

--отображает отдел первого работника

CREATE function department_of_worker5(@worker_id int)
RETURNS TABLE  
AS  
RETURN   
(
Select department.name From department Inner join worker ON worker.dep_id= department.id
Where worker.id =@worker_id
);

Create procedure show_dep6
as
Select * From worktime.dbo.department_of_worker(1);

Execute show_dep6;

-- Курсор. Функция которая использует курсор, чтобы пройтись по таблице и обновить значения 
CREATE PROCEDURE cursor1 AS

DECLARE	@id int
DECLARE	@dif nvarchar(max)

 DECLARE my_cur CURSOR FOR 
     SELECT id, difficulty
     FROM task

OPEN my_cur
 FETCH NEXT FROM my_cur INTO @id, @dif
 WHILE @@FETCH_STATUS = 0
   BEGIN
	if (@dif = 'Высокая') Update task set difficulty = '999' where id =@id
	FETCH NEXT FROM my_cur INTO @id, @dif
	end
CLOSE my_cur
   DEALLOCATE my_cur

Execute cursor1;

-- начальное заполнение таблиц


INSERT INTO department values('Главный отдел', '11-я Парковая улица, 36', 'Журавлев А.Д', '001')
INSERT INTO department values('Отдел разработки', 'улица Малая Пироговская, 1', 'Морозова В.А', '002')

INSERT INTO task values('Разработка приложения', 'дневная', '0001', '128','Высокая')
INSERT INTO task values('Тестирование приложения', 'вечерняя', '0002', '256','Низкая')
INSERT INTO task values('Устранение ошибок', 'дневная', '0003', '256','Средняя')

INSERT INTO worker values('Кононов Г.П','1','1')
INSERT INTO worker values('Копылов М.Д','1','1')
INSERT INTO worker values('Бурова Э.Г','2','2')
INSERT INTO worker values('Петрова М.Д','2','2')
INSERT INTO worker values('Горбачёва З.В','1','3')

INSERT INTO time_control values ('17.12.2020','12:25','18:26','1','1','0')
INSERT INTO time_control values ('20.12.2020','12:25','18:45','1','1','0')

INSERT INTO time_control values ('17.12.2020','12:25','21:28','2','1','0')

INSERT INTO time_control values ('16.12.2020','18:25','21:28','3','2','0')
INSERT INTO time_control values ('15.12.2020','00:00','11:00','3','2','0')

INSERT INTO time_control values ('15.12.2020','19:25','21:28','4','2','0')

INSERT INTO time_control values ('18.12.2020','11:25','21:44','5','3','0')
INSERT INTO time_control values ('22.12.2020','14:25','19:11','5','3','0')
INSERT INTO time_control values ('28.12.2020','09:25','15:33','5','3','0')
INSERT INTO time_control values ('31.12.2020','17:25','21:33','5','3','0')

--Создание ролей

CREATE LOGIN Artem WITH PASSWORD='123'
CREATE USER ArtemUser FOR LOGIN Artem

GRANT Insert ON time_control TO ArtemUser
GRANT Select ON time_control TO ArtemUser
GRANT Select ON department TO ArtemUser
GRANT Select ON task TO ArtemUser
GRANT Select ON worker TO ArtemUser

CREATE LOGIN Admin WITH PASSWORD='123'
CREATE USER AdminUser FOR LOGIN Admin

GRANT Select, Update, Delete ON department TO AdminUser
GRANT Select, Update, Delete ON worker TO AdminUser
GRANT Select, Update, Delete ON task TO AdminUser
GRANT Select, Update, Delete ON time_control TO AdminUser
