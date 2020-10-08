-- churn = cancellations / total subscribers

-- create temprary table to produce the time period for each month
WITH months AS (
	SELECT -- Janurary
		'2017-01-01' AS first_day,
		'2017-01-31' AS last_day
	UNION
	SELECT -- February
		'2017-02-01' AS first_day,
		'2017-02-28' AS last_day
	UNION
	SELECT -- March
		'2017-03-01' AS first_day,
		'2017-03-31' AS last_day
)
SELECT *
FROM months;


-- select all customers who are active during the specified time period (January):
WITH enrollments AS (
	SELECT *
	FROM subscriptions
	-- Select the cutoff date (do not count new_subscriptions during the month of January)
	WHERE subscription_start < '2017-01-01'
	AND (
		-- select those who ended only during January
		(subscription_end >= '2017-01-01')
		-- or haven't ended their subscription yet
		OR (subscription_end IS NULL)
	)
),

status AS (
	SELECT
	CASE
		WHEN (subscription_end > '2017-01-31')
		OR (subscription_end IS NULL) THEN 0
		ELSE 1
	END AS is_canceled,
	CASE
		WHEN subscription_start < '2017-01-01'
		AND (
			(subscription_end >= '2017-01-01')
			OR (subscription_end IS NULL)
		) THEN 1
		ELSE 0
	END AS is_active
	FROM enrollments
)
SELECT 1.0 * SUM(is_canceled) / SUM(is_active) AS 'churn'
FROM status;



-- FINAL calculation
WITH months AS (
	SELECT -- January
		'2017-01-01' AS first_day,
		'2017-01-31' AS last_day
	UNION
	SELECT -- February
		'2017-02-01' AS first_day,
		'2017-02-28' AS last_day
	UNION
	SELECT -- March
		'2017-03-01' AS first_day,
		'2017-03-31' AS last_day
),

cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
),

status AS (
	SELECT id, first_day AS month,
	CASE
		WHEN (subscription_start < first_day)
			AND (
				subscription_end > first_day
				OR subscription_end IS NULL
			) THEN 1
		ELSE 0
	END AS is_active,
	CASE 
		WHEN subscription_end BETWEEN first_day AND last_day THEN 1
		ELSE 0
	END AS is_canceled
	FROM cross_join
),

status_aggregate AS (
  SELECT month,
    SUM(is_active) AS 'active',
    SUM(is_canceled) AS 'canceled'
  FROM status
  GROUP BY month
)

SELECT month,
	1.0 * canceled / active AS 'churn_rate'
FROM status_aggregate;
