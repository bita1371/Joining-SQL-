#a_mkt_data as marketing 
#b_lead_data as new_lead_data  ( the date format needed to change in order to import into sql table )

# Create the Lead Data table


ALTER TABLE new_lead_data
MODIFY COLUMN lead_date DATE;

#Rename marketing_channel values in lead table to match them with marketing_channel in marketing table 
UPDATE new_lead_data
SET marketing_channel =
    CASE
        WHEN marketing_channel = 'google display' THEN 'Search'
        WHEN marketing_channel = 'seo' THEN 'Search'
        WHEN marketing_channel = 'Social network' THEN 'Social'
        ELSE marketing_channel
    END;
#disable safe updates 
  set SQL_SAFE_UPDATES = 0;    
  
  
#Combining tables as ONE single table 
CREATE TABLE combined_data AS
SELECT
    m.date,
    m.marketing_channel,
    SUM(m.impressions) AS total_impressions,
    SUM(m.clicks) AS total_clicks,
    SUM(m.cost) AS total_cost,
    l.lead_id,
    l.lead_date,
    l.score
FROM
    marketing m
LEFT JOIN
    new_lead_data l
ON
    m.date = l.lead_date 
   AND m.marketing_channel = l.marketing_channel
GROUP BY
   m.marketing_channel,m.date;            #deponds on our need we can modify grouoby; GROUP BY m.marketing_channel
#I could remove 
#since we are looking for qualify leads , scores = 0 removed from combined table , lead_id = 0 removed 
DELETE FROM combined_data
WHERE score = 0 OR lead_id = 0;

#to check which channel works better for marketing table
SELECT
    mkt_channel_ma AS marketing_channel,
    FORMAT(SUM(total_impressions), 0) AS total_impressions,
    FORMAT(SUM(total_clicks), 0) AS total_clicks,
    FORMAT(SUM(avg_cost) / SUM(total_clicks), 2) AS avg_cost_per_click
FROM combined_data
GROUP BY mkt_channel_ma;

# to check marketing_channel analysis in combine_table 
SELECT
    marketing_channel,
    FORMAT(SUM(total_impressions), 0) AS total_impressions,
    FORMAT(SUM(total_clicks), 0) AS total_clicks,
    FORMAT(SUM(avg_cost) / SUM(total_clicks), 2) AS avg_cost_per_click
FROM (
    SELECT
        mkt_channel_ma AS marketing_channel,
        total_impressions,
        total_clicks,
        avg_cost
    FROM combined_data
    UNION ALL
    SELECT
        mkt_channel_lead AS marketing_channel,
        total_impressions,
        total_clicks,
        avg_cost
    FROM combined_data
) AS combined_data_union
GROUP BY marketing_channel;
# marketing_channel	total_impressions	total_clicks	avg_cost_per_click
#Native	272,768,173,185	173,375,106	0.33
#Search	112,400,527	10,013,595	0.21
#Social	26,248,924,832	153,038,297	1.20	



