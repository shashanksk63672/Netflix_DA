select * from netflix
where rating like '%min'


--1 the number of tv shows and movies

select type , count(*) as total_number from netflix
group by 1


-- 2 f/o most common rating for movies and tv shows
select type , rating from
( 
select type ,rating,  count(*),
RANK ()OVER(PARTITION BY type order by count(*) desc) as ranking -- here we are givinh ranking to most rated and then we filter out the first from each
 from netflix
group by 1,2
) as t1 
where ranking = 1


--  3 list all the movies that are realesd in 2020

select title as movie_name from netflix
where type = 'Movie' and release_year = 2020


-- 4 find the top 5 countries with most content on netflix

-- here we have a problem that the country name have multiple entries so we have to seprate out each count
-- here we will use string to array function and unnest over it so we will gwt different countries

select 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, 
	   count(show_id) as total_content
	   from netflix
	   group by 1 
	   order by 2 desc
	   limit 5
	   
-- 	 5 f/o the maximum lenght of a movie

-- SUBSTRING(duration,1,POSITION(' ' IN duration)-1)  this will extract number from duration string 
-- cast function make the number(which is string) to an integer value and max will return the maximum lenght


select title, max(CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT)) as maximun_lenght
from netflix
where type = 'Movie' and duration is not null
group by 1
order by 2 desc

--  6 find content added in last 5 years

select *
from netflix
where 
		TO_DATE(date_added, 'Month DD, YYYY') >= current_date - INTERVAL '5 Years'
		
		
-- 7 find all the movies / tv shows which are directed by 'Rajiv chilaka'

select title from netflix
where director like '%Rajiv Chilaka%'

-- 8 find all the tv show whose season are more than 5
select *, CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT) as seasons from netflix
where type = 'TV Show' and CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT) > 5
order by seasons desc
	
-- 9	count the number of genre of each content 
select 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre , count(*)
from netflix
group by 1
order by 2 desc

-- 10 find each year and the average number of content realsed in india every year return top 5 avg

select Extract(year from to_date(date_added, 'Month DD, YYYY')) as year , 
count(*),
round(count(*)*100.00/ (select count(*) from netflix where country like '%India%'),2) as avg_added
from netflix
where country like '%India%'
group by 1
order by 2 desc


--  11 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

with new_table
as (
select
case
	when description ILIKE '%kill%' OR
 	description ILIkE'%violence%' then 'Bad'
	else 'Good'
	end as category,
*
from netflix
)
select category , count(*) as total_count from new_table

group by 1
