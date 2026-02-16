-- Исправленный скрипт SQL запросов
-- Все запросы сохранены по смыслу, но изменен синтаксис и структура

-- № 1. Подсчет уникальных артистов в рейтинге

SELECT COUNT(DISTINCT `artist(s)_name`) AS total_unique_artists
FROM songs;

-- № 2. Лидеры по прослушиваниям за 2023 год

SELECT `artist(s)_name` AS artist_name,
       SUM(streams) AS total_streams_2023
FROM songs
WHERE released_year = 2023
GROUP BY artist_name
ORDER BY total_streams_2023 DESC
LIMIT 5;

-- № 3. Самые плодовитые артисты в чарте

SELECT `artist(s)_name` AS performer,
       COUNT(*) AS number_of_tracks
FROM songs
GROUP BY performer
ORDER BY number_of_tracks DESC
LIMIT 5;

-- № 4. Артисты с несколькими треками и высоким средним числом прослушиваний

SELECT `artist(s)_name` AS artist,
       ROUND(AVG(streams), 0) AS average_streams_per_track,
       COUNT(*) AS tracks_quantity
FROM songs
GROUP BY artist
HAVING tracks_quantity > 1
ORDER BY average_streams_per_track DESC
LIMIT 5;

-- № 5. Самые популярные треки за все время

SELECT track_name AS song_title,
       `artist(s)_name` AS performer,
       streams AS listen_count
FROM songs
ORDER BY listen_count DESC
LIMIT 10;

-- № 6. Лучшие новинки 2023 года

SELECT track_name AS song,
       `artist(s)_name` AS artist,
       streams AS total_listens
FROM songs
WHERE released_year = 2023
ORDER BY total_listens DESC
LIMIT 5;

-- № 7. Распределение треков по декадам

SELECT CONCAT(CAST(FLOOR(released_year / 10) * 10 AS CHAR), 's') AS release_decade,
       COUNT(*) AS track_count
FROM songs
GROUP BY release_decade
ORDER BY release_decade;

-- № 8. Характеристики самых популярных треков

SELECT track_name AS title,
       `artist(s)_name` AS artist,
       bpm AS beats_per_minute,
       mode AS musical_mode
FROM songs
ORDER BY streams DESC
LIMIT 10;

-- № 9. Анализ темпа и тональности по декадам

SELECT CONCAT(CAST(FLOOR(released_year / 10) * 10 AS CHAR), 's') AS decade_period,
       COUNT(*) AS total_tracks,
       ROUND(AVG(bpm), 0) AS average_bpm,
       ROUND(SUM(CASE WHEN mode = 'Major' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS major_percentage,
       ROUND(SUM(CASE WHEN mode = 'Minor' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS minor_percentage
FROM songs
GROUP BY decade_period
ORDER BY decade_period;

-- № 10. Эмоциональный окрас треков в чарте

WITH valence_stats AS (
    SELECT 
        COUNT(*) AS total_songs,
        SUM(CASE WHEN `valence_%` < 30 THEN 1 ELSE 0 END) AS low_valence_cnt,
        SUM(CASE WHEN `valence_%` > 70 THEN 1 ELSE 0 END) AS high_valence_cnt
    FROM songs
)
SELECT 
    ROUND(high_valence_cnt * 100.0 / total_songs, 0) AS optimistic_tracks_percent,
    ROUND(low_valence_cnt * 100.0 / total_songs, 0) AS pessimistic_tracks_percent,
    ROUND((total_songs - low_valence_cnt - high_valence_cnt) * 100.0 / total_songs, 0) AS neutral_tracks_percent
FROM valence_stats;

-- № 11. Популярность музыкальных тональностей

SELECT `key` AS musical_key,
       COUNT(*) AS tracks_in_key
FROM songs
WHERE `key` IS NOT NULL AND `key` != ''
GROUP BY musical_key
ORDER BY tracks_in_key DESC;

-- № 12. Сезонность релизов и их успех

SELECT 
    CASE 
        WHEN released_month = 12 OR released_month = 1 OR released_month = 2 THEN 'Winter'
        WHEN released_month BETWEEN 3 AND 5 THEN 'Spring'
        WHEN released_month BETWEEN 6 AND 8 THEN 'Summer'
        WHEN released_month BETWEEN 9 AND 11 THEN 'Autumn'
    END AS release_season,
    COUNT(*) AS number_of_tracks,
    ROUND(AVG(streams), 0) AS avg_listens,
    MAX(streams) AS max_listens,
    MIN(streams) AS min_listens
FROM songs
GROUP BY release_season
ORDER BY release_season;

-- № 13. Сезонные характеристики треков

SELECT 
    CASE 
        WHEN released_month IN (12, 1, 2) THEN 'Winter season'
        WHEN released_month IN (3, 4, 5) THEN 'Spring season'
        WHEN released_month IN (6, 7, 8) THEN 'Summer season'
        WHEN released_month IN (9, 10, 11) THEN 'Autumn season'
    END AS season_name,
    ROUND(AVG(`danceability_%`), 1) AS avg_danceability_score,
    ROUND(AVG(`energy_%`), 1) AS avg_energy_score,
    ROUND(AVG(`valence_%`), 1) AS avg_positivity_score
FROM songs
GROUP BY season_name
ORDER BY season_name;

-- № 14. Пересечение топ-чартов Spotify и Apple Music

WITH spotify_top AS (
    SELECT track_name, 
           `artist(s)_name`,
           in_spotify_charts
    FROM songs
    ORDER BY in_spotify_charts DESC 
    LIMIT 10
),
apple_music_top AS (
    SELECT track_name, 
           `artist(s)_name`,
           in_apple_charts
    FROM songs
    ORDER BY in_apple_charts DESC 
    LIMIT 10
)
SELECT 
    s.track_name AS song_title,
    s.in_spotify_charts AS spotify_chart_entries,
    a.in_apple_charts AS apple_music_chart_entries
FROM spotify_top s
INNER JOIN apple_music_top a ON s.track_name = a.track_name AND s.`artist(s)_name` = a.`artist(s)_name`;

-- № 15. Треки, популярные в плейлистах всех платформ

WITH spotify_playlists AS (
    SELECT track_name, 
           `artist(s)_name`,
           in_spotify_playlists AS spotify_playlist_count
    FROM songs
    ORDER BY spotify_playlist_count DESC 
    LIMIT 10
),
apple_playlists AS (
    SELECT track_name, 
           `artist(s)_name`,
           in_apple_playlists AS apple_playlist_count
    FROM songs
    ORDER BY apple_playlist_count DESC 
    LIMIT 10
),
deezer_playlists AS (
    SELECT track_name, 
           `artist(s)_name`,
           in_deezer_playlists AS deezer_playlist_count
    FROM songs
    ORDER BY deezer_playlist_count DESC 
    LIMIT 10
)
SELECT 
    sp.track_name AS popular_track,
    sp.spotify_playlist_count,
    ap.apple_playlist_count,
    dp.deezer_playlist_count
FROM spotify_playlists sp
JOIN apple_playlists ap ON sp.track_name = ap.track_name AND sp.`artist(s)_name` = ap.`artist(s)_name`
JOIN deezer_playlists dp ON sp.track_name = dp.track_name AND sp.`artist(s)_name` = dp.`artist(s)_name`;