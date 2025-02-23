-- Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.
select brand from "transaction" t 
where t.standard_cost > '1500'

-- Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.
select * from "transaction" t 
where order_status = 'Approved'
and t.transaction_date between '01.04.2017' and '09.04.2017'

-- Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.
select job_title from customer
where job_title like 'Senior%'

-- Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services
select distinct brand from "transaction" t 
inner join customer c on t.customer_id  = c.customer_id 
where c.job_industry_category  = 'Financial Services'

-- Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.
select c.customer_id, c.first_name, c.last_name from customer c 
inner join "transaction" t on t.customer_id = c.customer_id
where t.online_order = true 
and t.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
limit 10

-- Вывести всех клиентов, у которых нет транзакций
select c.customer_id, c.first_name, c.last_name from customer c 
Left join "transaction" t on t.customer_id = c.customer_id
where t.transaction_id  is null

-- Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.
select distinct c.customer_id, c.first_name, c.last_name, max(t.standard_cost) from customer c 
inner join "transaction" t on t.customer_id = c.customer_id
where c.job_industry_category  = 'IT'
group by c.customer_id, c.first_name, c.last_name

-- Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.
select c.customer_id, c.first_name, c.last_name from customer c 
inner join "transaction" t on t.customer_id = c.customer_id
where c.job_industry_category  in ('IT','Health')
and t.transaction_date  between '07.07.2017' and '17.07.2017'
and t.order_status = 'Approved'


