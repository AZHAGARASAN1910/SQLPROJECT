use world ;

SELECT * FROM `bank customer churn prediction`;
RENAME TABLE `bank customer churn prediction` TO bank_customer_churn_prediction;

select distinct country from bank_customer_churn_prediction;
select count(*) from bank_customer_churn_prediction;
select round(avg(tenure)) avg_tempure from bank_customer_churn_prediction;
select churn,count(*) from bank_customer_churn_prediction group by churn;

DESCRIBE bank_customer_churn_prediction;



update bank_customer_churn_prediction
set country = null
where customer_id =15565714;

select*from bank_customer_churn_prediction;

update bank_customer_churn_prediction
set credit_score =null
where customer_id = 15565996;

set sql_safe_updates =0;

-- calculate rounded men values using user_define fun
set @credict_score_avg =(select avg(credit_score) from bank_customer_churn_prediction);
select @credict_score_avg;

update bank_customer_churn_prediction
set credit_score = @credict_score_avg
where credit_score is null;

-- calculate rounded mode values using user_define fun
set @country_mode =(select country from bank_customer_churn_prediction group by country order by count(*) desc limit 1);
select @country_mode;

-- input mode   for the specfic colom
update bank_customer_churn_prediction
set country = @country_mode
where country is null;

-- model outlier in credict_score column
delete from bank_customer_churn_prediction
where  credit_score>850 or credit_score <400;

-- column rename
alter table bank_customer_churn_prediction
rename column products_number to products_count,
rename column credit_card to cedict_card_holder;

-- create new columns
alter table bank_customer_churn_prediction
add column member_status enum('active','inactive'),
add column churned enum ('yes','no');

-- set values new columns based on existing data
update bank_customer_churn_prediction
set member_status = if (active_member=1,'active','inactive'),
churned = if ( churn = 1,'yes','no');

select*from bank_customer_churn_prediction;

UPDATE bank_customer_churn_prediction
SET 
  member_status = IF(active_member = 1, 'active', 'inactive'),
  churned = IF(churn = 1, 'yes', 'no')
WHERE customer_id IS NOT NULL;

-- column drop
alter table bank_customer_churn_prediction
drop column churn,
drop column active_member;

# data exploration and analysis

-- total number of customer by gender
select gender,count(*) as customer_count from bank_customer_churn_prediction
group by gender;

-- average age of customer who churned
select floor (avg(age)) as avg_age from bank_customer_churn_prediction where churned='yes';

-- prectange of customer who churned
select churned,concat(round(count(*)/(select count(*) from bank_customer_churn_prediction)*100,2),'%')as churn_precentage
from bank_customer_churn_prediction
group by churned;

-- average credit_score of customer who churned vs stayed
select churned, round(avg(credit_score)) as avg_credit_score
from bank_customer_churn_prediction
group by churned;

-- churn rate by country
select country,count(*)/ (select count(*) from bank_customer_churn_prediction where churned = 'yes')*100 as churn_rate
from bank_customer_churn_prediction
where churned ='yes'
group by country;

-- average balance by tenure
select tenure ,round(avg(balance),2) as avg_balance
from bank_customer_churn_prediction 
group by tenure
order by tenure;

-- churn rate among customer with credit cards
SELECT 
    IF(cedict_card_holder = 1, 'yes', 'no') AS had_credit_card,
    COUNT(*) / (
        SELECT COUNT(*) 
        FROM bank_customer_churn_prediction 
        WHERE cedict_card_holder = 1
    ) * 100 AS churn_rate
FROM bank_customer_churn_prediction
WHERE churned = 'yes'
GROUP BY cedict_card_holder;

-- churned customer who are active member and credit card 
select count(*) as chruned_activemember_creditcard from bank_customer_churn_prediction
where churned = 'yes' and cedict_card_holder = 1 and member_status = 'active';

-- churned  customer with  hogh credict score
select count(*) as highcredictscore_chrunedcustomer
from bank_customer_churn_prediction
where churned = 'yes' and credit_score >800;

-- customer who are active member and inactive member
select member_status,count(*) as customer_count
from bank_customer_churn_prediction
group by member_status;

-- gender wise inactive who chruned
select gender,count(*) as inacttive_customer_count
from bank_customer_churn_prediction
group by gender;

-- average age customer churned customer by country
select country,round(avg(age)) as avg_age
from bank_customer_churn_prediction
where churned ='yes'
group by country;

-- zeero blace customer
select churned, count(*) as customer_withzero_balance
from bank_customer_churn_prediction
where balance =0 
group by churned;

-- customer churn by age group
select 
	case
		when age < 30 then '18-30'
		when age between 30 and 39 then '30-39'
		when age between 40 and 49 then '40-49'
		when age between 50 and 59 then '50-59'
		else '60+'
 
 end as age_group,
 count(*) as churned_customer
 from bank_customer_churn_prediction
 where churned = 'yes'
 group by age_group
 order by age_group;
 
 -- cte --comman table ecperssion with
 -- cte to calculate average credict score of customer churned ,grouped by gender and country 
 -- and from cte ,identify the countries with heist and low avg credict score among customer churned
 with cte_churned_customer as (
 select gender,country, avg(credict_score) as avg_credict_score
 from bank_customer_churn_prediction
 where churned = 'yes'
 group by gender,country)
 
 select country,gender,avg_credict_score,
	case
		when avg_credict_score = (select max(avg_credict_score) from bank_customer_churn_prediction) then 'highest'
        when avg_credict_score = (select min(avg_credict_score) from bank_customer_churn_prediction) then 'lowest'
        else 'other'
	end  as credict_categroy
    from cte_churned_customer
	order by  countr,gender;
    
    
    
    WITH cte_churned_customer AS (
  SELECT 
    gender,
    country,
    AVG(credict_score) AS avg_credict_score
  FROM bank_customer_churn_prediction
  WHERE churned = 'yes'
  GROUP BY gender, country
)
SELECT  
  gender,
  country,
  avg_credict_score,
  CASE
    WHEN avg_credict_score = (SELECT MAX(avg_credict_score) FROM cte_churned_customer) THEN 'highest'
    WHEN avg_credict_score = (SELECT MIN(avg_credict_score) FROM cte_churned_customer) THEN 'lowest'
    ELSE 'other'
  END AS credict_category
FROM cte_churned_customer
ORDER BY country, gender;
