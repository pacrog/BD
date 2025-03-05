--Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества. 
SELECT job_industry_category,count(*) as cnt FROM customers c 
GROUP BY c.job_industry_category 
ORDER BY cnt desc

-- Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности
SELECT 
    TO_CHAR(t.transaction_date, 'YYYY-MM') AS month,
    c.job_industry_category,                          
    SUM(t.list_price) AS total_transaction_amount    
FROM 
    public.transactions t
JOIN 
    public.customers c ON t.customer_id = c.customer_id 
WHERE
    t.transaction_date IS NOT NULL  
GROUP BY 
    month, 
    c.job_industry_category                  
ORDER BY 
    month,                                    
    c.job_industry_category       

-- Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT.
SELECT 
    t.brand,                                 
    COUNT(*) AS online_order_count            
FROM 
    public.transactions t
JOIN 
    public.customers c ON t.customer_id = c.customer_id  
WHERE 
    c.job_industry_category = 'IT'   
    AND t.order_status = 'Approved'                    
    AND t.online_order = true                      
GROUP BY 
    t.brand                         
ORDER BY 
    online_order_count DESC

-- Найти по всем клиентам сумму всех транзакций (list_price), 
-- максимум, минимум и количество транзакций, отсортировав результат по убыванию суммы транзакций и количества клиентов
-- через group by
SELECT 
    t.customer_id, c.first_name, c.last_name,
    SUM(t.list_price) AS total_transaction_amount,  
    MAX(t.list_price) AS max_transaction_amount,   
    MIN(t.list_price) AS min_transaction_amount,  
    COUNT(*) AS transaction_count   
FROM 
    public.transactions t
JOIN 
    public.customers c ON t.customer_id = c.customer_id  
GROUP BY 
    t.customer_id, c.first_name, c.last_name                                    
ORDER BY 
    total_transaction_amount DESC,                     
    transaction_count DESC;                            

-- через оконки
SELECT 
    t.customer_id, c.first_name, c.last_name,
    SUM(t.list_price) OVER (PARTITION BY t.customer_id) AS total_transaction_amount,
    MAX(t.list_price) OVER (PARTITION BY t.customer_id) AS max_transaction_amount,  
    MIN(t.list_price) OVER (PARTITION BY t.customer_id) AS min_transaction_amount,  
    COUNT(*) OVER (PARTITION BY t.customer_id) AS transaction_count         
FROM 
    public.transactions t
JOIN 
public.customers c ON t.customer_id = c.customer_id  
ORDER BY 
    total_transaction_amount DESC,                         
    transaction_count DESC;                                
-- сравнение результатов
 Через окна вышло существенно больше строк т.к. по каждому заказу идёт

-- Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период (сумма транзакций не может быть null).

-- минимальная сумма
 SELECT c.first_name, c.last_name
FROM public.customers c
JOIN (
    SELECT customer_id, SUM(list_price) AS total_transaction_amount
    FROM public.transactions
    WHERE list_price IS NOT NULL
    GROUP BY customer_id
) ts ON c.customer_id = ts.customer_id
WHERE ts.total_transaction_amount = (SELECT MIN(total_transaction_amount) FROM (
    SELECT customer_id, SUM(list_price) AS total_transaction_amount
    FROM public.transactions
    WHERE list_price IS NOT NULL
    GROUP BY customer_id
) subquery)

-- максимальная сумма
SELECT c.first_name, c.last_name
FROM public.customers c
JOIN (
    SELECT customer_id, SUM(list_price) AS total_transaction_amount
    FROM public.transactions
    WHERE list_price IS NOT NULL
    GROUP BY customer_id
) ts ON c.customer_id = ts.customer_id
WHERE ts.total_transaction_amount = (SELECT MAX(total_transaction_amount) FROM (
    SELECT customer_id, SUM(list_price) AS total_transaction_amount
    FROM public.transactions
    WHERE list_price IS NOT NULL
    GROUP BY customer_id
) subquery)


--Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций.
SELECT customer_id, transaction_id, transaction_date
FROM (
    SELECT customer_id, transaction_id, transaction_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date) AS rn
    FROM public.transactions
) t
WHERE t.rn = 1


--Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал вычисляется в днях)
WITH transaction_dates AS (
    SELECT customer_id, transaction_date,
           LEAD(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS next_transaction_date
    FROM public.transactions
)
, date_intervals AS (
    SELECT customer_id, 
           EXTRACT(DAY FROM (next_transaction_date - transaction_date)) AS transaction_interval,
           first_name, last_name, job_title
    FROM public.customers c
    JOIN transaction_dates td ON c.customer_id = td.customer_id
    WHERE next_transaction_date IS NOT NULL
)
SELECT first_name, last_name, job_title
FROM date_intervals
WHERE transaction_interval = (SELECT MAX(transaction_interval) FROM date_intervals)

