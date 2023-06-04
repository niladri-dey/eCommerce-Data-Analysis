SELECT * FROM mavenfuzzyfactory.website_sessions;

/* 
lets check how utm_content(advertisement/campaign content name)
perform as per session and as per session how much orders
*/

SELECT 
	website_sessions.utm_content,
	COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
	COUNT(DISTINCT orders.order_id) AS Orders,
    	ROUND(COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id),3) AS CVR
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 
	utm_content
ORDER BY
	Sessions DESC;
    
    
/*
ASSIGNMENT1.
Understand where the bluk of website sessions
are comming from through 12 April,2012 with a breakdown by
UTM source-campaign-referring domain-sessions
*/

SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at <'2012-04-12'
GROUP BY
	utm_source,
    utm_campaign,
    http_referer
ORDER BY
	sessions DESC
;
    
/*
ASSIGNMENT2:
Calculate the conversion rate (CVR) from session to order.
As per requirment it needs a CVR of atleast 4% to make the numbers work
*/
SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS 	conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.utm_source='gsearch' 
	AND website_sessions.created_at <'2012-04-14'
    AND website_sessions.utm_campaign ='nonbrand'
;	
    
/*
ASSIGNMENT3:GSEARCH VOLUME TRANDS BEFORE 2012-05-10
Pull gsearch nonbrand trended session volume by week
Using DATE function YEAR(column_name),WEEK(column_name)
*/
SELECT 
	MIN(DATE(created_at)) AS Week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at< '2012-05-10'
	AND utm_source='gsearch'
    AND utm_campaign='nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEk(created_at)
;
/*
ASSIGNMENT4:GSEARCH DEVICE LEVEL PERFORMENCE
*/
SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS CVR
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at<'2012-05-11'
	AND website_sessions.utm_source='gsearch'
    	AND website_sessions.utm_campaign='nonbrand'
GROUP BY 
	device_type
;
/*
ASSIGNMENT5: gsearch DEVICE LEVEL TRENDS UNTILL 2012-04-15 
Here breakdown 
week_start_date - desktop_session - mobile_session
concept-->PIVOTING DATA WITH COUNT AND CASE
*/
SELECT
	MIN(DATE(created_at)) AS week_started_at,
    COUNT(
		DISTINCT CASE WHEN device_type='desktop'
		THEN website_session_id ELSE NULL END
        )
    AS desktop_sessions,
    COUNT(
		DISTINCT CASE WHEN device_type='mobile'
		THEN website_session_id ELSE NULL END
        )
    AS mobile_sessions
FROM website_sessions
WHERE created_at>'2012-04-15'
	AND created_at<'2012-06-09'
	AND utm_source='gsearch'
    	AND utm_campaign='nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at)
;
