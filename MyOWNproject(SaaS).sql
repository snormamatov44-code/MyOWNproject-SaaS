--CLEANING PROCESS--

SELECT*
FROM own..feature_usage;
UPDATE own..feature_usage
SET usage_date = FORMAT(TRY_CAST(usage_date AS DATE), 'dd/MM/yyyy');
ALTER TABLE own..feature_usage
ALTER COLUMN usage_duration_secs DECIMAL(10,2);
UPDATE own..feature_usage
SET usage_duration_secs= ROUND(usage_duration_secs/60.0,2); 
USE OWN;
EXEC sp_rename 'dbo.feature_usage.usage_duration_secs', 'usage_duration_mins', 'COLUMN';
UPDATE own..feature_usage
SET feature_name=REPLACE(feature_name,'feature_','')
SUM(TRY_CAST(f.usage_count AS INT)) AS total_feature_actions

SELECT* 
FROM own..subscriptions;
UPDATE own..subscriptions
SET start_date=FORMAT(TRY_CAST(start_date AS DATE),'dd/MM/yyyy')
UPDATE own..subscriptions
SET end_date = NULL
WHERE end_date = '01/01/1900';
USE OWN; 
ALTER TABLE own..subscriptions
ALTER COLUMN seats INT;
ALTER TABLE own..subscriptions 
ALTER COLUMN mrr_amount DECIMAL(10,2);
ALTER TABLE own..subscriptions
ALTER COLUMN arr_amount DECIMAL(10,2);
--SOURCE OF OUR ACTIVE REVENUE COMING
SELECT plan_tier,
  COUNT(*) AS active_subscribers,
  SUM(seats) AS seats_sold,
  SUM(mrr_amount) AS total_mrr,
  SUM(arr_amount) AS total_arr,
  AVG(mrr_amount) AS avg_customer_value
FROM own..subscriptions
GROUP BY plan_tier
ORDER BY total_mrr
--OUR HIGH-LEVEL CHURN RATE--
SELECT 
  COUNT(*) AS lifetime_signups,
  SUM(CASE WHEN churn_flag= 'True' THEN 1 ELSE 0 END) AS historical_cancellations,
  CAST(SUM(CASE WHEN churn_flag= 'True' THEN 1 ELSE 0 END)AS FLOAT)/COUNT(*) *100 AS lifetime_churn_rate_pct	
FROM own..subscriptions;

SELECT *
FROM dbo.support_tickets
UPDATE dbo.support_tickets
SET submitted_at = FORMAT(TRY_CAST(submitted_at AS DATE), 'dd/MM/yyyy');
UPDATE dbo.support_tickets
SET closed_at = CASE 
    WHEN closed_at = '' OR closed_at IS NULL THEN NULL
    ELSE FORMAT(TRY_CAST(closed_at AS DATE), 'dd/MM/yyyy')
END;
UPDATE dbo.support_tickets
  SET priority=UPPER(TRIM(priority));
UPDATE dbo.support_tickets
  SET satisfaction_score= CASE WHEN satisfaction_score ='' THEN NULL ELSE satisfaction_score END , 
      escalation_flag= CASE WHEN escalation_flag=''THEN NULL ELSE escalation_flag END
ALTER TABLE dbo.support_tickets
ALTER COLUMN resolution_time_hours DECIMAL(10,2);
ALTER TABLE dbo.support_tickets
ALTER COLUMN first_response_time_minutes INT;
ALTER TABLE dbo.support_tickets 
ALTER COLUMN satisfaction_score DECIMAL(3,1);
SELECT 
    priority,
    COUNT(*) AS total_tickets_handled,
    ROUND(AVG(CAST(first_response_time_minutes AS FLOAT)), 1) AS avg_first_reply_mins,
    ROUND(AVG(CAST(resolution_time_hours AS FLOAT)), 1) AS avg_resolution_hours,
    ROUND(AVG(CAST(satisfaction_score AS FLOAT)), 2) AS avg_customer_satisfaction
FROM dbo.support_tickets
GROUP BY priority
ORDER BY avg_resolution_hours DESC;
-- WORKING IN DETAIL
SELECT*
FROM dbo.feature_usage;
SELECT*
FROM dbo.subscriptions;
SELECT*
FROM dbo.accounts;
;WITH FeatureMetrics AS (
  SELECT 
        sub.account_id,
        SUM(TRY_CAST(f.usage_count AS INT)) AS total_feature_actions,
        COUNT(DISTINCT f.feature_name) AS unique_features_used
    FROM dbo.feature_usage f
    INNER JOIN dbo.subscriptions sub
	ON f.subscription_id = sub.subscription_id
    GROUP BY sub.account_id
), 
SupportMetrics AS (
    SELECT 
        account_id,
        COUNT(*) AS total_tickets,
        ROUND(AVG(CAST(resolution_time_hours AS FLOAT)), 1) AS avg_resolution_hours
    FROM dbo.support_tickets
    GROUP BY account_id
)
    SELECT 
	  s.account_id,
	  s.plan_tier, 
	  s.mrr_amount,
	  ISNULL(f.total_feature_actions,0) AS total_clicks,
	  ISNULL(f.unique_features_used, 0) AS features_adopted ,
	  ISNULL(sup.total_tickets , 0) AS support_tickets_filed,
	  ISNULL(sup.avg_resolution_hours,0) AS support_speed_hours,
	  CASE WHEN s.churn_flag= 'True' THEN 'CHURNED ACCOUNT' ELSE 'ACTIVE CUSTOMER' END AS status,
	  DENSE_RANK() OVER (
        PARTITION BY s.plan_tier 
        ORDER BY ISNULL(f.total_feature_actions, 0) DESC
    ) AS usage_rank_in_tier
	FROM dbo.subscriptions s 
	LEFT JOIN FeatureMetrics f
	ON s.account_id=f.account_id
	LEFT JOIN SupportMetrics sup
	ON s.account_id=sup.account_id
    ORDER BY s.mrr_amount DESC, total_clicks DESC	
	

