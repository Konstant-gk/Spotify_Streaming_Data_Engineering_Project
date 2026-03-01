{{ config(materialized='view') }}

SELECT
    song_id,
    song_name,
    artist_name,
    COUNT(CASE WHEN event_type = 'play' THEN 1 END) AS total_plays,
    COUNT(CASE WHEN event_type = 'skip' THEN 1 END) AS total_skips
FROM {{ ref('spotify_silver') }}
GROUP BY 1, 2, 3
ORDER BY total_plays DESC