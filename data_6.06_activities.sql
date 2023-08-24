use bank;
/*
---------------------------------------------------------------
					LESSON 1: IF ELSE
---------------------------------------------------------------


In this example, we will use the same query that we used before 
and try to build on that query. The objective is 
to make the result more interactive by displaying 
the result as "Red Zone", "Green Zone", or "Orange Zone", 
based on the company's brackets 
(brackets/groups of the average loss made by a region). 
You will see the calculation for loss in the query below.

*/
drop procedure if exists average_loss_status_regiom_proc;

delimiter //
create procedure average_loss_status_regiom_proc (in param1 varchar(10), in param2 varchar(100), out param3 varchar(20))
begin
  declare avg_loss_region float default 0.0;
  declare zone varchar(20) default "";

  select round((sum(amount) - sum(payments))/count(*), 2) into avg_loss_region
  from (
    select a.account_id, d.A2 as district, d.A3 as region, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
    join bank.loan l
    on l.account_id = a.account_id
    where l.status COLLATE utf8mb4_general_ci = param1
    and d.A3 COLLATE utf8mb4_general_ci = param2
  ) sub1;
select avg_loss_region;

  if avg_loss_region > 70000 then
    set zone = 'Red Zone';
  elseif avg_loss_region <= 70000 and avg_loss_region > 40000 then
    set zone = 'Orange Zone';
  else
    set zone = 'Green Zone';
  end if;

  select zone into param3;
end;
//
delimiter ;

call average_loss_status_regiom_proc("A", "Prague", @x);

select @x;


# 6.06 Activity 1

# In this activity, you will be still using data from files_for_activities/mysql_dump.sql. 
# Refer to the case study files to find more information. 
# Please answer the following questions.

# Update the query just created on the class to include another condition the query for duration column from loan table. 
# Pick up any value for duration (from the given values in the table loan) to test your code.


drop procedure if exists duration_proc;

delimiter //
create procedure duration_proc (in param1 varchar(10), in param2 varchar(100), in param3 int, out param4 varchar(20))
begin
  declare avg_loss_region float default 0.0;
  declare zone varchar(20) default "";

  select round((sum(amount) - sum(payments))/count(*), 2) into avg_loss_region
  from (
    select a.account_id, d.A2 as district, d.A3 as region, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
    join bank.loan l
    on l.account_id = a.account_id
    where l.status COLLATE utf8mb4_general_ci = param1
    and d.A3 COLLATE utf8mb4_general_ci = param2
    and l.duration COLLATE utf8mb4_general_ci = param3
  ) sub1;
select avg_loss_region;

  if avg_loss_region > 70000 then
    set zone = 'Red Zone';
  elseif avg_loss_region <= 70000 and avg_loss_region > 40000 then
    set zone = 'Orange Zone';
  else
    set zone = 'Green Zone';
  end if;

  select zone into param4;
end;
//
delimiter ;

call duration_proc("A", "Prague", 24, @x);

select @x;


/*
---------------------------------------------------------------
	LESSON 2: Conditional Statements with stored procedures
---------------------------------------------------------------
*/

drop procedure if exists average_loss_status_regiom_proc;

delimiter //
create procedure average_loss_status_regiom_proc (in param1 varchar(10), in param2 varchar(100), out param3 varchar(20))
begin
  declare avg_loss_region float default 0.0;
  declare zone varchar(20) default "";
  select round((sum(amount) - sum(payments))/count(*), 2) into avg_loss_region
  from (
    select a.account_id, d.A2 as district, d.A3 as region, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
    join bank.loan l
    on l.account_id = a.account_id
    where l.status COLLATE utf8mb4_general_ci = param1
    and d.A3 COLLATE utf8mb4_general_ci = param2
  ) sub1;

  select avg_loss_region;

  case
    when avg_loss_region > 50000 then
      set zone = 'PLATINUM';
    when avg_loss_region <= 50000 AND avg_loss_region > 10000 then
      set zone = 'GOLD';
  else
    set zone = 'SILVER';
  end case;

  select zone into param3;
end;
//
delimiter ;

call average_loss_status_regiom_proc("A", "Prague", @x);
select @x;

# 6.06 Activity 2

# In this activity we will use the trans table in the bank database.

# Use the case statements to classify the balances as positive and negative.

# Use a stored procedure to execute the query.

drop procedure if exists balance_trans_proc;

delimiter //
create procedure balance_trans_proc ()
begin

 SELECT balance, case
    when balance >= 0 then
      'Positive'
  else
    'Negative' end as Balance_Status  
 from trans;

end;
//
delimiter ;

call balance_trans_proc();


/*
---------------------------------------------------------------
						LESSON 3: Handlers
---------------------------------------------------------------
*/

drop procedure if exists update_account_table;

delimiter //
create procedure update_account_table (in param1 int, in param2 int, in param3 varchar(100), in param4 int, out param5 varchar(100))
begin
  declare HasError char(100) default 'Table updated!';
  declare continue handler for sqlexception set HasError = 'This account already exists in the database';
  insert into bank.account values(param1, param2, param3, param4);
  -- we are using param 5 to return if the query was executed or not.
  select HasError into param5;

end;
//
delimiter ;

call update_account_table(1,1,"131313", 31, @x);
select @x;

/*
check the account table in the database and see what 
values of account_id are present and which are not. 
Try to update the table with different values 
using the stored procedure and observe the results
*/

# 6.06 Activity 3
# Answer the following questions:

# Update the query just created on the class to use continue to exit instead of using declare continue handler.
# Did you get there a difference in the output? If yes, what is the difference between the results?

drop procedure if exists update_account_table2;

delimiter //
create procedure update_account_table2 (in param1 int, in param2 int, in param3 varchar(100), in param4 int, out param5 varchar(100))
begin
  declare HasError char(100) default 'Table updated!';
  declare exit handler for sqlexception SELECT 'This account already exists in the database' message;
  insert into bank.account values(param1, param2, param3, param4);
  -- we are using param 5 to return if the query was executed or not.
  select HasError into param5;

end;
//
delimiter ;

call update_account_table2(1,1,"131313", 31, @x);

select @x;
