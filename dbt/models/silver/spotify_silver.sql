WITH bronze_data AS (SELECT
        event_id,
        user_id,
        song_id,
        artist_name,
        song_name,
        device_type,
        country,
        event_type,
        TRY_TO_TIMESTAMP_TZ(timestamp) AS event_ts
    FROM {{ source('bronze', 'spotify_events_bronze') }}
)
SELECT *
FROM bronze_data
WHERE event_id IS NOT NULL
    AND user_id IS NOT NULL
    AND song_id IS NOT NULL
    AND event_ts IS NOT NULL

