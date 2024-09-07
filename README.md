# Netflix Movies and TV Shows Data Analysis using SQL
![Netflix Logo](https://github.com/shashanksk63672/Netflix_DA/blob/main/logo.png)
## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select type , count(*) as total_number from netflix
group by 1
```
**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

``` sql
select type , rating from
( 
select type ,rating,  count(*),
RANK ()OVER(PARTITION BY type order by count(*) desc) as ranking -- here we are givinh ranking to most rated and then we filter out the first from each
 from netflix
group by 1,2
) as t1 
where ranking = 1
```
**Objective:** Identify the most frequently occurring rating for each type of content.


### 3. List All Movies Released in a Specific Year (e.g., 2020)

``` sql
select title as movie_name from netflix
where type = 'Movie' and release_year = 2020
```

**Objective:** Retrieve all movies released in a specific year.


### 4. Find the Top 5 Countries with the Most Content on Netflix


``` sql
select 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, 
	   count(show_id) as total_content
from netflix
group by 1 
order by 2 desc
limit 5
```
**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie
```sql
select title, max(CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT)) as maximun_lenght
from netflix
where type = 'Movie' and duration is not null
group by 1
order by 2 desc
```
**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years
```sql
select *
from netflix
where 
		TO_DATE(date_added, 'Month DD, YYYY') >= current_date - INTERVAL '5 Years'
```
**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select title from netflix
where director like '%Rajiv Chilaka%'
```
**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons
```sql
select *, CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT) as seasons from netflix
where type = 'TV Show' and CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT) > 5
order by seasons desc
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre
```sql
select 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre , count(*)
from netflix
group by 1
order by 2 desc
```
**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
### return top 5 year with highest avg content release!
```sql
select Extract(year from to_date(date_added, 'Month DD, YYYY')) as year , 
count(*),
round(count(*)*100.00/ (select count(*) from netflix where country like '%India%'),2) as avg_added
from netflix
where country like '%India%'
group by 1
order by 2 desc
```
**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
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
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
