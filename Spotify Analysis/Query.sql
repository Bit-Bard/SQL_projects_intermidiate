-- Spotify Analysis

CREATE DATABASE sql_p4;
USE sql_p4;

-- CREATE TABLE
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- Load Dataset
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/dhruv/OneDrive/Documents/Desktop/SQL projects/Spotify Analysis/cleaned_dataset.csv'
INTO TABLE spotify
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
ESCAPED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(artist, track, album, album_type, danceability, energy, loudness, speechiness, acousticness, instrumentalness, liveness, valence, tempo, duration_min, title, channel, views, likes, comments, licensed, official_video, stream, energy_liveness, most_played_on);

SELECT * FROM spotify;

-- EDA
SELECT count(*) FROM spotify; 
SELECT DISTINCT(artist), COUNT(DISTINCT(artist)) FROM spotify;
SELECT COUNT(DISTINCT(artist)) FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * 
FROM spotify WHERE duration_min=0;

DELETE FROM spotify
WHERE duration_min=0;

-- Data Analysis --> Base category

-- Q1. Retreive the name of all the track that have more than 1 billion stream
SELECT * FROM spotify
WHERE stream > 10000000;

-- Q2. List all albumns along with thier repective artist
SELECT DISTINCT(album), artist
FROM spotify
ORDER BY 1;

-- Q3. Get total number of comments from track where licensed = True
SELECT SUM(comments) 
FROM spotify
WHERE licensed= 'true';

-- Q4. Find all the track where album type is single
SELECT *
FROM spotify
WHERE album_type='single';

-- Q5. Find total number of track by each artist
SELECT artist, COUNT(track) 
FROM spotify
GROUP BY 1
ORDER BY 2 DESC ;

-- Data Analysis --> Medium Category
-- Q6. Calculate the Average Danceability of tracks in each album
  SELECT 
	album, ROUND(AVG(danceability), 2) AS Avg_Danceability
  FROM spotify
  GROUP BY 1 
  ORDER BY 2 DESC;
  
  -- Q7. Find the top 5 tracks with the highest energy values
  SELECT DISTINCT(track), MAX(energy)
  FROM spotify
  GROUP BY 1
  ORDER BY 2 DESC LIMIT 5;
  
  -- Q8. List all the tracks with thier likes and views where official video =True
SELECT 
	track, 
	SUM(likes) AS total_likes,
    SUM(views) AS total_views
FROM spotify
GROUP BY 1
ORDER BY 2 DESC ;

-- Q9. for each album, calculate total views of all associated tracks
SELECT album, track, SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC ;

-- Q10. Retrieve the track name that have been streamed on on spotify more than youtube
SELECT * FROM 
(
	SELECT 
		track,
		COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS most_played_on_spotify,
		COALESCE(SUM(CASE WHEN most_played_on = 'youtube' THEN stream END), 0) AS most_played_on_youtube
	FROM spotify
	GROUP BY 1
) as t1
WHERE most_played_on_spotify > most_played_on_youtube AND most_played_on_youtube != 0;

-- Data Analyze --> Advanced Category

-- Q.11 find the top 3 most viewed tracks for each artist using window fucntion 
SELECT * FROM
(
	SELECT 
		artist, 
		track,
		SUM(views),
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC )AS ranking
	FROM 
	spotify
	GROUP BY 1,2
) as t1
WHERE ranking <=3
ORDER BY artist;

-- Q12. Write a Query to find a tracks where the liveness score is above average 
SELECT artist, track, liveness
FROM 
spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify) 
ORDER BY liveness;

-- Q13. Use a with clause to find the difference between the highest and lowest energy values for tracks in each album
WITH cte
AS
(
	SELECT 
		album,
		MAX(energy) as Highest_energy,
		MIN(energy) AS Lowest_energy
	FROM
	spotify
	GROUP BY album
)
SELECT 
	album, 
    ROUND(Highest_energy - Lowest_energy, 2) AS Energy_Difference
FROM cte
ORDER BY Highest_energy - Lowest_energy DESC







