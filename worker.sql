
use worktime

-- �������� ������
/* 
ALTER TABLE time_control
   DROP CONSTRAINT time_control_to_worker 
DROP TABLE worker;
DROP TABLE time_control;
DROP TABLE department;
DROP TABLE task;
*/

-- �������� � ���������� ������ 

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

-- ������� ��� ������� time_control, ������� ������������� ������� ���������� ����� ����������� �� ������

CREATE TRIGGER total_time_count ON time_control
AFTER INSERT, UPDATE
AS UPDATE time_control
Set total_time = ROUND(DATEDIFF(minute, time_in, time_out)/60.0,2)
WHERE id = (SELECT Id FROM inserted);


 -- ������ �. ����������� ���� ���������� �� ������ � �����, ���� �� ������ ������ ��� ����� 256, ���������� �� ��� ����������
 Select fio, task.name 'task', task.work_hours, task.difficulty, department.name 'department', "������������" =
 CASE 
	When task.work_hours >=256 THEN '����������'
	else '�� ����������'
END
 FROM department 
 INNER JOIN worker ON department.id = worker.dep_id
  INNER JOIN task ON worker.task_id = task.id;

 create function a()
 returns table 
 as 
return(
  Select fio, task.name 'task', task.work_hours, task.difficulty, department.name 'department', "������������" =
 CASE 
	When task.work_hours >=256 THEN '����������'
	else '�� ����������'
END
 FROM department 
 INNER JOIN worker ON department.id = worker.dep_id
  INNER JOIN task ON worker.task_id = task.id
 );

 select * from a()

  -- ������ b.������� � ������������ ���������� ������� ���� ��� �������� ������ 8 ����� ����� �������������� view 

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
 
 -- ������ �.

 --�.1 �����������������

SELECT * FROM task
WHERE work_hours > (SELECT AVG(work_hours) FROM task)

SELECT * from (Select * from time_control) as total

Select (Select Count(*) from task), name from task


--c.2 ��������������� 

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
     WHERE t.id = t2.task_id) AS "����������� ��������� ������� � ����"
FROM task AS t;

SELECT t.difficulty, t.name, (SELECT MAx(t2.total_time) FROM time_control as t2 WHERE t.id = t2.task_id) AS "����������� ��������� ������� � ����" FROM task AS t;


--������ d. ��������������� ������ ������� ���������� ������ �� ��� � ������� ��������� ������� ����, ��� � ���� ��������� ������������� ����� ������ 10 �����

Select fio, count(*) as '���������� ����', total_time
From time_control 
Inner join worker ON time_control.worker_id= worker.id
Group by fio, total_time
Having SUM(total_time) > 10

create function d()
 returns table 
 as 
return(
Select fio, count(*) as '���������� ����', total_time
From time_control 
Inner join worker ON time_control.worker_id= worker.id
Group by fio, total_time
Having SUM(total_time) > 10
);

SELECT * from d()
--������ e. ���������� ���������� 2 ��������� � ������� ���� ����� ������ ������ ��� � ���� ����������� 2 ���������

SELECT Distinct fio
            FROM time_control
 INNER JOIN worker ON time_control.worker_id= worker.id
 Where total_time > ALL(Select total_time FROM time_control 
 INNER JOIN worker ON time_control.worker_id= worker.id
 Where dep_id ='1')
 
SELECT Distinct fio, total_time FROM time_control INNER JOIN worker ON time_control.worker_id= worker.id Where total_time > ALL(Select total_time FROM time_control INNER JOIN worker ON time_control.worker_id= worker.id Where dep_id ='1')


 -- �������� �������� 

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


--������������� ��������� � ��������� ������� 

--���������� ����� ������� � �������
Create function hours_to_min(@work_hours int)
returns int
AS 
BEGIN  
    DECLARE @min int;  
	Set @min = @work_hours * 60;
	RETURN @min;  
End;

SELECT name, worktime.dbo.hours_to_min(work_hours) as "� �������"  from task

--���������� ����� ������� ���������

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

-- ������. ������� ������� ���������� ������, ����� �������� �� ������� � �������� �������� 
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
	if (@dif = '�������') Update task set difficulty = '999' where id =@id
	FETCH NEXT FROM my_cur INTO @id, @dif
	end
CLOSE my_cur
   DEALLOCATE my_cur

Execute cursor1;

-- ��������� ���������� ������


INSERT INTO department values('������� �����', '11-� �������� �����, 36', '�������� �.�', '001')
INSERT INTO department values('����� ����������', '����� ����� �����������, 1', '�������� �.�', '002')

INSERT INTO task values('���������� ����������', '�������', '0001', '128','�������')
INSERT INTO task values('������������ ����������', '��������', '0002', '256','������')
INSERT INTO task values('���������� ������', '�������', '0003', '256','�������')

INSERT INTO worker values('������� �.�','1','1')
INSERT INTO worker values('������� �.�','1','1')
INSERT INTO worker values('������ �.�','2','2')
INSERT INTO worker values('������� �.�','2','2')
INSERT INTO worker values('��������� �.�','1','3')

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

--�������� �����

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
