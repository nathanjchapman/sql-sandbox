-- SIMPLE FIRST-TOUCH ATTRIBUTION
WITH first_touch AS (
	SELECT user_id,
		MIN(timestamp) AS 'first_touch_at'
	FROM page_visits
	GROUP BY user_id)
SELECT ft.user_id,
	ft.first_touch_at,
	pv.utm_source
FROM first_touch AS 'ft'
JOIN page_visits AS 'pv'
	ON ft.user_id = pv.user_id
	AND ft.first_touch_at = pv.timestamp;

-- SIMPLE LAST-TOUCH ATTRIBUTION
WITH last_touch AS (
	SELECT user_id,
		MAX(timestamp) AS 'last_touch_at'
	FROM page_visits
	GROUP BY user_id)
SELECT ft.user_id,
	ft.last_touch_at,
	pv.utm_source
FROM last_touch AS 'ft'
JOIN page_visits AS 'pv'
	ON ft.user_id = pv.user_id
	AND ft.last_touch_at = pv.timestamp;



-- FIND CAMPAIGN SOURCES
WITH first_touch AS (
	SELECT user_id,
		MIN(timestamp) as first_touch_at
	FROM page_visits
	GROUP BY user_id
),

ft_attr AS (
  SELECT ft.user_id,
		ft.first_touch_at,
		pv.utm_source,
		pv.utm_campaign
  FROM first_touch ft
  JOIN page_visits pv
	ON ft.user_id = pv.user_id
	AND ft.first_touch_at = pv.timestamp
)

SELECT ft_attr.utm_source AS 'source',
	   ft_attr.utm_campaign AS 'campaign',
	   COUNT(*) AS 'count'
FROM ft_attr
GROUP BY ft_attr.utm_source
ORDER BY count DESC;

-- AND LAST TOUCH
WITH last_touch AS (
	SELECT user_id,
		MAX(timestamp) as last_touch_at
	FROM page_visits
	GROUP BY user_id
),

lt_attr AS (
  SELECT lt.user_id,
		lt.last_touch_at,
		pv.utm_source,
		pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
	ON lt.user_id = pv.user_id
	AND lt.last_touch_at = pv.timestamp
)

SELECT lt_attr.utm_source AS 'source',
		lt_attr.utm_campaign AS 'campaign',
		COUNT(*) AS 'count'
FROM lt_attr
GROUP BY lt_attr.utm_source
ORDER BY count DESC;