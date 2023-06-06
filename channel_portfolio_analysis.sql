USE mavenfuzzyfactory;

-- ASSIGNMENT1:EXPENDED CHANNEL PORTFOLIO
 -- As launched second paid search channel bsearch
   -- compare with gsearch-nonbrand with bsearch
   
SELECT
	MIN(DATE(created_at)) AS week_started_at,
    	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    	COUNT(DISTINCT CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    	COUNT(DISTINCT CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at > '2012-08-22'
	AND created_at < '2012-11-29'
    	AND utm_campaign = 'nonbrand' -- limiting to nonbrand paid search
GROUP BY YEARWEEK(created_at);

-- ASSIGNMENT2:COMPARING MARKETING CHANNELS
 -- pull the percentage of traffic comming on mobile and compare to that with gsearch
 SELECT
	utm_source,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    	COUNT(DISTINCT 
			CASE WHEN device_type = 'mobile' 
				THEN website_sessions.website_session_id ELSE NULL END
	     ) AS mobile_session,
	COUNT(DISTINCT 
			CASE WHEN device_type = 'mobile' 
				THEN website_sessions.website_session_id ELSE NULL END
	     )/COUNT(DISTINCT website_sessions.website_session_id)
         AS percentage_mobile
	

FROM website_sessions
 WHERE created_at> '2012-08-22'
	AND created_at< '2012-11-30'
    AND utm_campaign ='nonbrand'
GROUP BY 
	utm_source
;

-- ASSIGNMENT3:MULTI CHANNEL BIDDING
 -- pull nonbrand conversion rates from session to order for 
 -- gsearch and bsearch,and slice the data by device type
 -- from august 22 to september 18
 SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)
		AS conversion_rate
    
 FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
	
 WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-09-19'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	website_sessions.device_type,
    website_sessions.utm_source
;

-- ASSIGNMENT4:IMPACT OF BID CHANGES
 -- Pull weekly session volume for gsearch and bsearch
 -- nonbrand,broken down by device ,since november 4th
 -- also include a comparision metric to show bsearch
 -- as a percent of gsearch
 
 SELECT
	MIN(DATE(created_at)) AS week_started_at,
    COUNT(
			DISTINCT 
				CASE WHEN utm_source='gsearch' AND device_type='desktop'
				     THEN website_session_id
                                     ELSE null
				END
		) AS gsearch_pc_session,
	COUNT(
			DISTINCT 
				CASE WHEN utm_source='bsearch' AND device_type='desktop'
				     THEN website_session_id
                                     ELSE null
				END
		) AS bsearch_pc_session,

-- calculating percentage 
    COUNT(
			DISTINCT 
				CASE WHEN utm_source='bsearch' AND device_type='desktop'
				     THEN website_session_id
                                     ELSE null
				END
		)/
	    COUNT(
			DISTINCT 
				CASE WHEN utm_source='gsearch' AND device_type='desktop'
				     THEN website_session_id
                                     ELSE null
				END
		) AS bsearch_percentage_gsearch_pc,
        
    COUNT(
			DISTINCT 
				CASE WHEN utm_source='gsearch' AND device_type='mobile'
				     THEN website_session_id
                                      ELSE null
				END
		) AS gsearch_mobile_session,
    COUNT(
			DISTINCT 
				CASE WHEN utm_source='bsearch' AND device_type='mobile'
				     THEN website_session_id
                                      ELSE null
				END
		) AS bsearch_mobile_session,


COUNT(
			DISTINCT 
				CASE WHEN utm_source='bsearch' AND device_type='mobile'
				     THEN website_session_id
                                      ELSE null
				END
		)/
COUNT(
			DISTINCT 
				CASE WHEN utm_source='gsearch' AND device_type='mobile'
				     THEN website_session_id
                                     ELSE null
				END
		) AS bsearch_percentge_gsearch_mob

 FROM website_sessions
 WHERE created_at> '2012-11-04'
	AND created_at< '2012-12-22'
    AND utm_campaign='nonbrand'
GROUP BY
	YEARWEEK(created_at)
;
-- ASSIGNMENT5:WEBSITE TRAFFIC BREAKDOWN
 -- pull organic search,direct type in and paid brand search
 -- sessions by month,and show those sessions as a% of paid 
 -- search nonbrand
 
 SELECT 
	YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group='paid_brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group='paid_brand' THEN website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_percent_of_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group='direct_type' THEN website_session_id ELSE NULL END) AS direct_search,
    COUNT(DISTINCT CASE WHEN channel_group='direct_type' THEN website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS directsearch_percent_of_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group='organic_search' THEN website_session_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN channel_group='organic_search' THEN website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS organicsearch_percent_of_nonbrand
    
    
 FROM(
	SELECT
	website_session_id,
    created_at,
	
		CASE
			WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic_search'
            WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type'
            WHEN utm_campaign = 'brand' THEN 'paid_brand'
            WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		END AS channel_group
 FROM website_sessions
 WHERE created_at< '2012-12-23'
 ) AS sessions_w_channel_group
 GROUP BY
		YEAR(created_at),
		MONTH(created_at)
;
    
 
 
	
 






