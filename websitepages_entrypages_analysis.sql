USE mavenfuzzyfactory;

SELECT
	pageview_url,
    	COUNT(DISTINCT website_pageview_id) AS page_views
FROM website_pageviews
WHERE website_pageview_id<1000
GROUP BY pageview_url
ORDER BY page_views DESC ;



-- ASSIGNMENT1:TOP WEBSITE PAGES
-- pulling most viewed website pages,ranked by session volume

SELECT 
	pageview_url,
    	COUNT(DISTINCT website_pageview_id) AS pageviews
FROM website_pageviews
WHERE created_at<'2012-06-09'
GROUP BY pageview_url
ORDER BY pageviews DESC;


-- ASSIGNMENT2:TOP LANDING/ENTRY PAGES
-- pull all entry pages and rank them entry volume


-- Concept of entry page analysis 
-- how to create temporary table for multiple analysis

-- STEP1-> Find the first_pageview for each sessions
-- STEP2-> Find the url the customer saw on that first pageview

CREATE TEMPORARY TABLE first_pageview_per_session
SELECT 
	website_session_id,
    	MIN(website_pageview_id) AS Min_pageviews
FROM website_pageviews
WHERE created_at<'2012-06-12'
GROUP BY website_session_id;

SELECT
    website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_pageview_per_session.website_session_id) AS session_hitting_lander
FROM first_pageview_per_session
LEFT JOIN website_pageviews
	ON first_pageview_per_session.Min_pageviews=website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url;


-- ASSIGNMENT 3: CALCULATING THE BOUNCE RATE OF HOME PAGE

-- STEP1:Finding the first website_pageview_id for relivant session
-- STEP2:Identify the landing page of each sesion
-- STEP3:Counting pageviews for each session,to identify 'bounce'
-- STEP4:Summerizing by counting total sessions and bounced sessions

CREATE TEMPORARY TABLE sec_pageview
SELECT 
	website_session_id,
    	MIN(website_pageview_id) AS Min_pageviews
FROM website_pageviews
WHERE created_at<'2012-06-14'
GROUP BY website_session_id;

-- now bring the landing page but home page only

CREATE TEMPORARY TABLE sessions_w_home_landingpage
SELECT 
	sec_pageview.website_session_id,
    	website_pageviews.pageview_url AS landing_page
FROM sec_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sec_pageview.Min_pageviews
	WHERE website_pageviews.pageview_url='/home';

-- Now create a temporary table to have count of pageviews per session
-- which is limited to bounced_sessions

CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landingpage.website_session_id,
    	sessions_w_home_landingpage.landing_page,
    	COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_home_landingpage
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_home_landingpage.website_session_id
GROUP BY 
	sessions_w_home_landingpage.website_session_id,
    sessions_w_home_landingpage.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id)=1;
	
select * from sessions_w_home_landingpage;

-- Final output as finding bounce_rate

SELECT 
	COUNT(DISTINCT sessions_w_home_landingpage.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
	COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landingpage.website_session_id) AS bounce_rate
FROM sessions_w_home_landingpage
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landingpage.website_session_id = bounced_sessions.website_session_id
;
-- ASSIGNMENT 4: ANALYZING LANDING PAGE TEST
-- Compair Lander1 and home page for gsearch nonbrand traffic

-- STEP0:Find out first when the new landing page launched
-- STEP1:Find out first relevant pageview_id for relevant session
-- STEP2:Identifying the landing page of each session
-- STEP3:Counting pageviews for each session,to identify bounces
-- STEP4:Summarizing total sessions and bounced session in landing page

SELECT
	MIN(created_at) AS launched_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url ='/lander-1'
	AND created_at IS NOT NULL
;
-- launched at : '2012-06-19 00:35:54'
-- first_pageview_id: '23504'

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at<'2012-07-28' -- as per assignment
        AND website_pageviews.website_pageview_id>23504 -- as per our finding
        AND website_sessions.utm_source ='gsearch'
        AND utm_campaign ='nonbrand'
GROUP BY 
	website_pageviews.website_session_id
;

-- now pull the landing page for each session restricted only for '/home' and '/lander-1'
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1')
;
CREATE TEMPORARY TABLE nonbrand_gsearch_bounced_sessions
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY 
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id)=1;
;

-- SELECT * FROM nonbrand_gsearch_bounced_sessions;

-- calculating final outpt

SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_gsearch_bounced_sessions.website_session_id) AS bounced_session_id,
    COUNT(DISTINCT nonbrand_gsearch_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_gsearch_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id=nonbrand_gsearch_bounced_sessions.website_session_id
GROUP BY 
		nonbrand_test_sessions_w_landing_page.landing_page
;

-- ASSIGNMENT5: LANDING PAGE TREND ANALYSIS

-- Pull the volume of paid search nonbrand traffic landing on
-- /home or /lander-1 trend weekly since JUNE 1st.
-- Also pull overall paid search bounce rate trend weekly

CREATE TEMPORARY TABLE sessions_w_minpageview_countviews
SELECT
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at>'2012-06-01'
	AND website_sessions.created_at<'2012-08-31'
    AND website_sessions.utm_source ='gsearch'
	AND utm_campaign ='nonbrand'
GROUP BY 
	website_sessions.website_session_id
;
-- SELECT * FROM sessions_w_minpageview_countviews;

CREATE TEMPORARY TABLE sessions_w_count_lander_and_created
SELECT
	sessions_w_minpageview_countviews.website_session_id,
    sessions_w_minpageview_countviews.first_pageview_id,
    sessions_w_minpageview_countviews.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_minpageview_countviews
	LEFT JOIN website_pageviews
		ON sessions_w_minpageview_countviews.first_pageview_id = website_pageviews.website_pageview_id
;

SELECT 
	YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_started,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews=1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews=1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS bounced_rate,
    COUNT(DISTINCT CASE WHEN landing_page='/home' THEN website_session_id ELSE NULL END) AS homepage_sessions,
    COUNT(DISTINCT CASE WHEN landing_page='/lander-1' THEN website_session_id ELSE NULL END) AS lander1_sessions
FROM sessions_w_count_lander_and_created
GROUP BY YEARWEEK(session_created_at)
;

-- ASSIGNMENT6:ANALYZING CONVERSION FUNNEL

-- STEP1:Select all pageviews for relivant sessions
-- STEP2:Identify each relivant pageview as tthe specific funnel step
-- STEP3:Create the session level conversion 
-- STEP4:aggregate the data to access funnel performance

SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
    CASE WHEN website_pageviews.pageview_url='/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN website_pageviews.pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN website_pageviews.pageview_url='/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url='/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN website_pageviews.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-08-05' 
	AND website_sessions.created_at< '2012-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
		website_sessions.website_session_id,
		website_pageviews.created_at
;

-- next we will put the previous query inside a query(subquery)
-- we will group by website_session_id,and take MAX() of each of the flag
-- this MAX() becomes a made_it flag for that session,to show the session made it there

SELECT
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mr_fuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
    CASE WHEN website_pageviews.pageview_url='/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN website_pageviews.pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN website_pageviews.pageview_url='/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url='/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN website_pageviews.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-08-05' 
	AND website_sessions.created_at< '2012-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
		website_sessions.website_session_id,
		website_pageviews.created_at

)AS pageview_level

GROUP BY
	website_session_id
;	
-- we will turn it into a temporary table
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mr_fuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
    CASE WHEN website_pageviews.pageview_url='/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN website_pageviews.pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN website_pageviews.pageview_url='/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url='/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN website_pageviews.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-08-05' 
	AND website_sessions.created_at< '2012-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
		website_sessions.website_session_id,
		website_pageviews.created_at

)AS pageview_level

GROUP BY
	website_session_id
;

-- OUTPUT1
SELECT
	COUNT(DISTINCT website_session_id)AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it=1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it=1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it=1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it=1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags;

-- then we will translate those counts to click rates for final output part2
 -- 
 
 SELECT
	COUNT(DISTINCT website_session_id)AS sessions,
    -- calculating lander_clickthroughrate
    COUNT(DISTINCT CASE WHEN product_made_it=1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT website_session_id) AS lander_clickedthrough_rate,
    
    -- calculating mrfuzzy_clickthroughrate
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END) 
     /COUNT(DISTINCT CASE WHEN product_made_it=1 THEN website_session_id ELSE NULL END)AS product_clickedthrough_rate,
    
    -- calculating cart_clickthroughrate
    COUNT(DISTINCT CASE WHEN cart_made_it=1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clickedthrough_rate,
    
    -- calculating shipping_clickthroughrate
    COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN cart_made_it=1 THEN website_session_id ELSE NULL END) AS shipping_clickedthrough_rate,
    
    -- calculating billing_clickthroughrate
    COUNT(DISTINCT CASE WHEN thankyou_made_it=1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END) AS billing_clickedthrough_rate,
    
    -- calculating thankyoupage_clickthroughrate
    COUNT(DISTINCT CASE WHEN billing_made_it=1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END) AS thanyoupage_clickedthrough_rate
FROM session_level_made_it_flags;

-- ASSIGNMENT7: ANALYZING CONVERSION FUNNEL TEST RESULTS
-- Want to test a updated billing page,want to look and see
-- wheather /billing-2 doing any better than /billing page

-- finding the /billing-2 starting point to frame the analysis

SELECT
	MIN(created_at) AS page_created_at,
	MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url='/billing-2'
;
-- page_created_at:'2012-09-10 00:13:05'
-- first_pv_id:'53550'

SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at<'2012-11-10'
	AND website_pageviews.website_pageview_id>= 53550
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
;

-- now warping as a subquery and summerizing
 -- aanalysis the final output
 SELECT
	billing_version,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM(
 SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at<'2012-11-10'
	AND website_pageviews.website_pageview_id>= 53550
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
 ) AS billing_sessions_w_orders
 GROUP BY 
	billing_version
 ;
 



