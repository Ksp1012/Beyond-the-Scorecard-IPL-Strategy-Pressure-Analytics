
-- LEVEL 1-FOUNDATIONAL CRICKET INSIGHTS

-- 1. How many matches are there in the dataset?
SELECT COUNT(*) FROM matches;

-- 2. How many seasons does datset covers?
SELECT COUNT(DISTINCT season) FROM matches;

-- 3. Which venues have hosted the most matches?
SELECT v.venue_standardized as Venue,COUNT(*) as total_match_played
FROM matches m
JOIN venue_dim v
ON m.venue =v.venue_original
GROUP BY 1
ORDER BY total_match_played DESC;

-- 4. Which teams have won the most matches?
SELECT match_won_by AS match_winner ,COUNT(*) as total_match_won
FROM matches
WHERE match_won_by IS NOT NULL 
GROUP BY 1
ORDER BY total_match_won DESC;

-- LEVEL 2: MATCH STRATEGY AND PERFORMANCE ANALYSIS

-- 1. Does winning the toss increase the chances of winning the match?
SELECT ROUND(100.0 * SUM(CASE WHEN toss_winner = match_won_by THEN 1 ELSE 0 END) / COUNT(*),2) AS toss_win_percent
FROM matches
WHERE match_won_by IS NOT NULL;
-- Analysis of 18 seasons of IPL data shows that teams winning the toss go on to win the match ~50.56% of the time, indicating a modest but consistent strategic advantage

-- 2. Is batting first or chasing more successful in the IPL?
SELECT
    COUNT(*) AS total_matches,
    SUM(CASE WHEN win_outcome LIKE '%runs%' THEN 1 ELSE 0 END) AS batting_first_wins,
    SUM(CASE WHEN win_outcome LIKE '%wickets%' THEN 1 ELSE 0 END) AS chasing_wins,
    ROUND(100.0 * SUM(CASE WHEN win_outcome LIKE '%runs%' THEN 1 ELSE 0 END) / COUNT(*), 2) AS batting_first_win_pct,
    ROUND(100.0 * SUM(CASE WHEN win_outcome LIKE '%wickets%' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chasing_win_pct
FROM matches
WHERE win_outcome IS NOT NULL;
-- Analysis of historical IPL results shows that teams chasing a target win approximately 53% of matches, indicating a consistent advantage when conditions are favorable, although match context plays a significant role


-- 3. Which venues favor chasing the most?
SELECT 
	v.venue_standardized AS venue,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN m.win_outcome LIKE '%wickets%' THEN 1 ELSE 0 END)  AS chasing_wins,
    ROUND(100*SUM(CASE WHEN m.win_outcome LIKE '%wickets%' THEN 1 ELSE 0 END)/COUNT(*),2) AS chasing_win_pct
FROM matches m
JOIN venue_dim v
ON v.venue_original=m.venue
WHERE win_outcome IS NOT NULL
GROUP BY 1
HAVING COUNT(*)>=20
ORDER BY chasing_win_pct DESC; 
-- Venue-level analysis shows that Sharjah (64.29%) and Sawai Mansingh Stadium, Jaipur (64.06%) strongly favor chasing, significantly exceeding the overall IPL chasing success rate (~53%). This highlights how venue conditions materially influence match strategy.


-- 4. Which teams are the best chasers in the IPL?
SELECT * FROM matches;

SELECT 
    match_won_by AS team,
    COUNT(*) AS total_wins,
    SUM(CASE WHEN win_outcome LIKE '%wickets%' THEN 1 ELSE 0 END) AS chasing_wins,
    ROUND(
        100.0 * SUM(CASE WHEN win_outcome LIKE '%wickets%' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS chasing_win_pct
FROM matches 
WHERE win_outcome IS NOT NULL
  AND match_won_by IS NOT NULL
  AND match_won_by <> 'Unknown'
GROUP BY match_won_by
HAVING COUNT(*) >= 20
ORDER BY chasing_win_pct DESC;
-- Team-level analysis shows that Delhi Daredevils and Rajasthan Royals are among the most effective chasing sides in IPL history (~63% and ~61% success respectively), while traditionally dominant teams such as MI and CSK exhibit lower chasing success, highlighting contrasting strategic strengths.

-- 5. Which teams are best at defending targets?
SELECT 
    match_won_by AS team,
    COUNT(*) AS total_wins,
    SUM(CASE WHEN win_outcome LIKE '%runs%' THEN 1 ELSE 0 END) AS defending_wins,
    ROUND(
        100.0 * SUM(CASE WHEN win_outcome LIKE '%runs%' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS defending_win_pct
FROM matches 
WHERE win_outcome IS NOT NULL
  AND match_won_by IS NOT NULL
  AND match_won_by <> 'Unknown'
GROUP BY match_won_by
HAVING COUNT(*) >= 20
ORDER BY defending_win_pct DESC;
-- Analysis reveals a strong inverse relationship between chasing and defending success. Teams such as LSG excel at defending totals (66.67% success) but struggle when chasing, while Delhi and Rajasthan dominate chases but underperform in defenses. This indicates clear strategic identities across franchises.

-- 6. Which venues are the hardest to defend at?
SELECT 
	v.venue_standardized AS venue,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN m.win_outcome LIKE '%runs%' THEN 1 ELSE 0 END)  AS defending_wins,
    ROUND(100*SUM(CASE WHEN m.win_outcome LIKE '%runs%' THEN 1 ELSE 0 END)/COUNT(*),2) AS defending_win_pct
FROM matches m
JOIN venue_dim v
ON v.venue_original=m.venue
WHERE win_outcome IS NOT NULL
GROUP BY 1
HAVING COUNT(*)>=20
ORDER BY defending_win_pct; 

-- Venue-level analysis reveals that Sharjah, Jaipur, and Abu Dhabi are among the hardest grounds to defend at, with defending success below 38%, while venues such as Chepauk remain strong defensive venues. This reinforces the critical role of pitch and conditions in IPL match outcomes.


-- LEVEL 3: Advanced Cricket Analytics

-- 1.Which teams perform best in high-pressure chases?(required run rate >=9  and ball_remaining<=30)
WITH pressure_moments AS(
SELECT s.match_id,
	   td.team_standardized as team
FROM(      
SELECT match_id,
	   batting_team,
       (120-team_balls) AS balls_remaining,
       (runs_target-team_runs) AS runs_remaining,
       ROUND((runs_target-team_runs)*6.0/NULLIF(120 - team_balls,0),2) AS required_run_rate
FROM deliveries
WHERE innings=2
) s
JOIN team_dim td
ON td.team_original = s.batting_team
WHERE required_run_rate>=9 
AND balls_remaining<=30
GROUP BY s.match_id,td.team_standardized
)
SELECT p.team AS team,
COUNT(*) AS total_pressure_chase,
SUM(CASE WHEN p.team =m.match_winner_std THEN 1 ELSE 0 END) AS won_pressure_chase,
ROUND(100*SUM(CASE WHEN p.team =m.match_winner_std THEN 1 ELSE 0 END)/COUNT(*),2) AS pressure_chase_win_pct
FROM pressure_moments p
JOIN matches_clean m 
ON m.match_id =p.match_id
GROUP BY p.team
HAVING COUNT(*)>10
ORDER BY pressure_chase_win_pct DESC;
-- Gujarat Titans dominate high-pressure chases with ~60% success, reflecting strong finishing depth and composure, especially during their 2022–23 peak seasons.
-- Most teams struggle under pressure (below 40%), with Pune Warriors performing the weakest (~9.5%), highlighting how crucial temperament and depth are in tight run chases.


-- 2. Which batters are the best finishers? (less than 18 balls and run remaining<=30)
WITH pressure_moments AS (
    SELECT 
        s.match_id,
        td.team_standardized AS team,
        s.batter,
        SUM(s.runs_batter) AS pressure_runs,
        COUNT(*) AS pressure_balls
    FROM (
        SELECT
            match_id,
            batting_team,
            batter,
            runs_batter,
            valid_ball,
            striker_out,
            (120 - team_balls) AS balls_remaining,
            (runs_target - team_runs) AS runs_remaining,
            ROUND((runs_target - team_runs) * 6.0 / NULLIF(120 - team_balls,0), 2) AS required_run_rate
        FROM deliveries
        WHERE innings = 2
    ) s
    JOIN team_dim td 
        ON td.team_original = s.batting_team
    WHERE 
        valid_ball = 1
        AND striker_out <> 1
        AND balls_remaining <= 18
        AND runs_remaining <= 30
        AND required_run_rate >= 8.5
    GROUP BY 
        s.match_id,
        td.team_standardized,
        s.batter
)

SELECT 
    p.team,
    p.batter,
    ROUND(AVG(100.0 * p.pressure_runs / p.pressure_balls), 2) AS avg_pressure_strike_rate,
    COUNT(*) AS total_clutch_situations,
    SUM(CASE WHEN p.team = m.match_won_by THEN 1 ELSE 0 END) AS clutch_wins,
    ROUND(100.0 * SUM(CASE WHEN p.team = m.match_won_by THEN 1 ELSE 0 END) / COUNT(*), 2) AS clutch_win_pct
FROM pressure_moments p
JOIN matches_clean m
    ON m.match_id = p.match_id
GROUP BY 
    p.team,
    p.batter
HAVING COUNT(*) > 5 AND  ROUND(AVG(100.0 * p.pressure_runs / p.pressure_balls), 2)>=150
ORDER BY clutch_win_pct DESC, avg_pressure_strike_rate DESC
LIMIT 10;
-- The analysis identifies elite finishers who consistently deliver under extreme pressure in chases.
-- Players like AT Rayudu (MI), David Miller (GT), SK Raina (CSK) and MS Dhoni (CSK) show exceptional finishing ability with strike rates above 170–230 and win involvement exceeding 80%, confirming their reputation as high-impact closers in tight matches.
-- Notably, MS Dhoni, despite a lower strike rate relative to others, leads in volume with 36 clutch situations, reinforcing his long-term reliability as the IPL’s most trusted finisher.


-- 3.Which bowlers are most effective at defending tight finishes?
WITH death_pressure AS (
    SELECT 
        d.match_id,
        td.team_standardized AS bowling_team,
        d.bowler,
        COUNT(*) AS pressure_balls,
        SUM(d.runs_total) AS pressure_runs_conceded,
        SUM(d.bowler_wicket) AS pressure_wickets
    FROM (
        SELECT
            match_id,
            bowling_team,
            bowler,
            runs_total,
            bowler_wicket,
            valid_ball,
            (120 - team_balls) AS balls_remaining,
            (runs_target - team_runs) AS runs_remaining,
            ROUND((runs_target - team_runs) * 6.0 / NULLIF(120 - team_balls,0), 2) AS required_run_rate
        FROM deliveries
        WHERE innings = 2
    ) d
    JOIN team_dim td
        ON td.team_original = d.bowling_team
    WHERE 
        valid_ball = 1
        AND balls_remaining <= 18
        AND runs_remaining <= 30
        AND required_run_rate >= 8.5
    GROUP BY 
        d.match_id,
        td.team_standardized,
        d.bowler
)

SELECT
    p.bowling_team,
    p.bowler,
    SUM(p.pressure_balls) AS total_pressure_balls,
    SUM(p.pressure_runs_conceded) AS total_runs_conceded,
    SUM(p.pressure_wickets) AS total_pressure_wickets,
    ROUND(6.0 * SUM(p.pressure_runs_conceded) / SUM(p.pressure_balls), 2) AS pressure_economy,
    COUNT(*) AS pressure_matches,
    SUM(CASE WHEN p.bowling_team = m.match_won_by THEN 1 ELSE 0 END) AS matches_defended,
    ROUND(
        100.0 * SUM(CASE WHEN p.bowling_team = m.match_won_by THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS defense_success_pct
FROM death_pressure p
JOIN matches_clean m
    ON m.match_id = p.match_id
GROUP BY
    p.bowling_team,
    p.bowler
HAVING 
	COUNT(*)>=5
ORDER BY
    defense_success_pct DESC,
    pressure_economy ASC,
    total_pressure_wickets DESC;
-- While several bowlers appear frequently in high-pressure death situations, the model reveals that some have a 0% defense success rate, indicating that despite being entrusted with critical overs, their teams failed to convert those moments into victories.
-- This highlights how death bowling effectiveness must be evaluated in the context of overall team performance, not just individual economy or wicket-taking ability