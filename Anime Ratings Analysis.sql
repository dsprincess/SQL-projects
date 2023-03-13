SELECT * From anime;

/*1 How many anime on the list?*/
SELECT COUNT(anime_name) AS total_anime
 FROM anime;
 
 /*2 Top 10 anime based on score*/
SELECT anime_name, ranking, score
	FROM anime
    ORDER BY score DESC
    LIMIT 10;
    
 /*3 Top 10 anime movie based on score*/
 SELECT anime_name, score, episodes
	FROM Anime
    WHERE episodes = 1
    ORDER BY score DESC
    LIMIT 10;
    
 /*4 Top 10 anime series based on score*/
 SELECT anime_name, score, episodes
	FROM anime
    WHERE episodes != 1
    ORDER BY score DESC
    LIMIT 10;
    
 /*5 Top 10 anime based on popularity (score is not null)*/
SELECT anime_name, popularity, score
	FROM anime
    WHERE score != 0
    ORDER BY popularity DESC
    LIMIT 10;

 /*6 Top 10 anime movie based on popularity (score is not null)*/
SELECT anime_name, popularity, score, episodes
	FROM anime
	WHERE episodes = 1 and score != 0
    ORDER BY popularity DESC
    LIMIT 10;
    
 /*6 Top 10 anime series based on popularity (score is not null)*/
SELECT anime_name, popularity, score, episodes
	FROM anime
	WHERE episodes > 1 and score != 0
    ORDER BY popularity DESC
    LIMIT 10;
    
 /*7 Top 10 ongoing anime series based on score*/
SELECT anime_name, score, episodes
	FROM anime
	WHERE episodes = 0
    ORDER BY score DESC
    LIMIT 10;
    
 /*8 Top 10 anime comedy series based on score*/
 SELECT anime_name, score, episodes, genres
	FROM anime
    WHERE episodes != 1 and genres LIKE '%Comedy%'
    ORDER BY score DESC
    LIMIT 10;
    
/*9 Mention the total no of animes which started in each release dates*/
SELECT release_date, COUNT(release_date) AS no_of_animes
FROM anime 
GROUP BY release_date
ORDER BY no_of_animes DESC;

/*10 Find a specific anime*/
SELECT *
FROM anime 
WHERE anime_name LIKE '%Naruto%';

SELECT *
FROM anime 
WHERE anime_name LIKE '%One Piece%';


/*10 Find the anime with highest and lowest score*/
SELECT anime_name, score AS top_score
FROM anime
WHERE score = (SELECT max(score) FROM anime);

SELECT anime_name, score AS lowest_score
FROM anime
WHERE score = (SELECT min(score) FROM anime WHERE score != 0);
    
/*11 Determine most no. of episodes for anime series*/

SELECT episodes, COUNT(anime_name) AS no_of_animes
FROM anime
WHERE episodes > 1
GROUP BY episodes
ORDER BY no_of_animes DESC
LIMIT 10;

    