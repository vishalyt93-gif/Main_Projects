

-- Categoryize products based on their price
SELECT ProductID,
		productName,
        Price,
		CASE WHEN Price < 50 then 'Low'
			 when Price between 50 and 200 then 'Medium'
             else 'High'
             end as price_category
	from products;
    

-- To join dim_customers with dim_geography to enrich customer data with geographic information   
    select c.CustomerID,  
			c.CustomerName,  
			c.Email, 
			c.Gender, 
			c.Age,  
			g.Country,  
			g.City
    from customers c
				left join geography g 
				on c.GeographyID = g.GeographyID;
 
 
 -- clean whitespace in reviews.
 select ReviewID,  
		CustomerID,  
		ProductID,  
		ReviewDate,  
		Rating,
		trim(ReviewText) as ReviewText
 from customer_reviews;
 
 
-- Query to clean and normalize the engagement_data table
 SELECT 
    EngagementID,  
    ContentID,    
    CampaignID,    
    ProductID,     
    UPPER(REPLACE(ContentType, 'Socialmedia', 'SocialMedia')) AS ContentType,  -- Normalize ContentType
    SUBSTRING_INDEX(ViewsClicksCombined, '-', 1) AS Views,  -- Extract Views before '-'
    SUBSTRING_INDEX(ViewsClicksCombined, '-', -1) AS Clicks, -- Extract Clicks after '-'
    Likes,         -- Number of likes
    EngagementDate  -- Format date as dd.mm.yyyy
FROM 
    engagement_data  -- Source table
WHERE 
    ContentType != 'Newsletter';  -- Exclude newsletters;
  

-- Common Table Expression (CTE) to identify and tag duplicate records and replace Null durations with Average value
SELECT 
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
    COALESCE(Duration, avg_duration) AS Duration
FROM 
    (
        SELECT 
            JourneyID,
            CustomerID,
            ProductID,
            VisitDate,
            UPPER(Stage) AS Stage,
            Action,
            Duration,
            round(AVG(Duration) OVER (PARTITION BY UPPER(Stage)),3) AS avg_duration,
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
                ORDER BY JourneyID
            ) AS row_num
        FROM 
            customer_journey
    ) AS subquery
WHERE 
    row_num = 1;
