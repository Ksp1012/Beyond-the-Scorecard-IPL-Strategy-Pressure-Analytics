-- CREATED A DATABASE 
CREATE DATABASE ipl_analysis;

-- USE THAT DATABASE 
USE ipl_analysis;

-- CREATED MAIN DATA TABLE
CREATE TABLE ipl_data (
    id INT PRIMARY KEY,

    match_id INT,
    match_date DATE,
    match_type VARCHAR(20),
    event_name VARCHAR(100),

    innings INT,
    batting_team VARCHAR(70),
    bowling_team VARCHAR(70),

    over_no INT,
    ball INT,
    ball_no DECIMAL(3,1),

    batter VARCHAR(100),
    bat_pos INT,
    runs_batter INT,
    balls_faced INT,

    bowler VARCHAR(100),
    valid_ball BOOLEAN,

    runs_extras INT,
    runs_total INT,
    runs_bowler INT,
    runs_not_boundary BOOLEAN,

    extra_type VARCHAR(30),

    non_striker VARCHAR(100),
    non_striker_pos INT,

    wicket_kind VARCHAR(30) NULL,
    player_out VARCHAR(100) NULL,
    fielders VARCHAR(100) NULL,

    runs_target INT NULL,

    review_batter VARCHAR(100) NULL,
    team_reviewed VARCHAR(70) NULL,
    review_decision VARCHAR(50) NULL,
    umpire VARCHAR(100) NULL,
    umpires_call BOOLEAN NULL,

    player_of_match VARCHAR(100),
    match_won_by VARCHAR(70),
    win_outcome VARCHAR(30),

    toss_winner VARCHAR(70),
    toss_decision ENUM('bat', 'field'),

    venue VARCHAR(150),
    city VARCHAR(70) NULL,

    match_day INT,
    match_month INT,
    match_year INT,
    season VARCHAR(15),

    gender VARCHAR(10),
    team_type VARCHAR(10),

    superover_winner VARCHAR(70) NULL,
    result_type VARCHAR(30),
    method VARCHAR(30) NULL,

    balls_per_over INT,
    overs INT,
    event_match_no varchar(20),
    stage VARCHAR(50) NULL,
    match_number VARCHAR(20) NULL,

    team_runs INT,
    team_balls INT,
    team_wicket INT,

    new_batter VARCHAR(100) NULL,
    batter_runs INT,
    batter_balls INT,
    bowler_wicket BOOLEAN NULL,

    batting_partners TEXT,
    next_batter VARCHAR(100) NULL,
    striker_out BOOLEAN NULL
);

-- CREATED A SIMILAR TABLE AS THE MAIN TABLE TO DEAL WITH THE DATATYPE ISSUE AND IMPORTING
create table ipl_data_stage LIKE ipl_data;

-- MODIFICATION IN DATA TYPE TO STORE THE ORIG. DATA FROM CSV
ALTER TABLE ipl_data_stage 
MODIFY runs_target VARCHAR(20);

-- IMPORTING THE DATA FROM ALTERNATE TABLE TO MAIN TABLE AND DEALING WITH THOSE DATATYPE ISSUE
INSERT INTO ipl_data (
    id, match_id, match_date, match_type, event_name,
    innings, batting_team, bowling_team,
    over_no, ball, ball_no,
    batter, bat_pos, runs_batter, balls_faced,
    bowler, valid_ball,
    runs_extras, runs_total, runs_bowler, runs_not_boundary,
    extra_type,
    non_striker, non_striker_pos,
    wicket_kind, player_out, fielders,
    runs_target,
    review_batter, team_reviewed, review_decision, umpire, umpires_call,
    player_of_match, match_won_by, win_outcome,
    toss_winner, toss_decision,
    venue, city,
    match_day, match_month, match_year, season,
    gender, team_type,
    superover_winner, result_type, method,
    balls_per_over, overs, event_match_no, stage, match_number,
    team_runs, team_balls, team_wicket,
    new_batter, batter_runs, batter_balls, bowler_wicket,
    batting_partners, next_batter, striker_out
)
SELECT
    id, match_id, match_date, match_type, event_name,
    innings, batting_team, bowling_team,
    over_no, ball, ball_no,
    batter, bat_pos, runs_batter, balls_faced,
    bowler, valid_ball,
    runs_extras, runs_total, runs_bowler, runs_not_boundary,
    extra_type,
    non_striker, non_striker_pos,
    wicket_kind, player_out, fielders,
    NULLIF(runs_target, ''),
    review_batter, team_reviewed, review_decision, umpire, umpires_call,
    player_of_match, match_won_by, win_outcome,
    toss_winner, toss_decision,
    venue, city,
    match_day, match_month, match_year, season,
    gender, team_type,
    superover_winner, result_type, method,
    balls_per_over, overs, event_match_no, stage, match_number,
    team_runs, team_balls, team_wicket,
    new_batter, batter_runs, batter_balls, bowler_wicket,
    batting_partners, next_batter, striker_out
FROM ipl_data_stage;

-- CHECKING IF THE ALL THE ROWS WERE IMPORTED PROPERLY
SELECT COUNT(*) FROM ipl_data_stage;
SELECT COUNT(*) FROM ipl_data;

DESCRIBE ipl_data;

-- CREATING A TABLE MATCHES (NORMALIZING THE IPL_DATA TABLE FOR BETTER PROCESS)
CREATE TABLE matches AS
SELECT DISTINCT 
	match_id,
    match_date,
    match_type,
    event_name,
    season,
    venue,
    city,
    team_type,
    gender,
    balls_per_over,
    overs,
    toss_winner,
    toss_decision,
    player_of_match,
    match_won_by,
    win_outcome,
    superover_winner,
    result_type,
    method
FROM ipl_data;

-- CHECKING IF ALL ROWS(MATCHES) ARE PRESENT 
SELECT COUNT(DISTINCT match_id) FROM ipl_data; -- 1169

SELECT COUNT(*) FROM matches; -- 1169

-- CREATING DELIVERIES TABLE SO THAT WE CAN HAVE PROPER DATA RELATED TO EACH DELIVERY
DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries AS
SELECT
    match_id,
    innings,
    batting_team,
    bowling_team,
    over_no,
    ball,
    ball_no,
    batter,
    non_striker,
    bowler,
    runs_batter,
    runs_extras,
    runs_total,
    valid_ball,
    wicket_kind,
    player_out,
    bowler_wicket,
    striker_out,
    team_runs,
    team_balls,
    runs_target,
    team_wicket
FROM ipl_data;
-- CHECKING NO. OF ROWS MATCHING WITH THE TOTAL NO. OF ROWS IN ipl_data
SELECT COUNT(*) FROM ipl_data;
SELECT COUNT(*) FROM deliveries;

-- CREATING A VENUE TABLE AFTER FINDING MULTIPLE ENTRIES OF SAME VENUE WITH DIFFERENT NAMES OR NOT PROPERLY MANITAINED
CREATE TABLE venue_dim(
	venue_original VARCHAR(150) PRIMARY KEY,
    venue_standardized VARCHAR(150)
);

-- inserting the original data
INSERT INTO venue_dim(venue_original,venue_standardized)
SELECT DISTINCT venue,venue
FROM matches;

-- checking all the venues
SELECT * FROM venue_dim ORDER BY venue_original;

-- updating arun jaitley Stadium (Arun Jaitley Stadium-Arun Jaitley Stadium, Delhi - Feroz Shah Kotla)
UPDATE venue_dim
SET venue_standardized = 'Arun Jaitley Stadium'
WHERE venue_original IN (
    'Feroz Shah Kotla',
    'Arun Jaitley Stadium',
    'Arun Jaitley Stadium, Delhi'
);

-- updating Brabourne Stadium Stadium (Brabourne Stadium-Brabourne Stadium, Mumbai)
UPDATE venue_dim
SET venue_standardized = 'Brabourne Stadium'
WHERE venue_original IN (
    'Brabourne Stadium',
    'Brabourne Stadium, Mumbai'
);

-- updating Dr DY Patil Sports Academy Stadium ( Dr DY Patil Sports Academy - Dr DY Patil Sports Academy,Mumbai)
UPDATE venue_dim
SET venue_standardized = 'Dr DY Patil Sports Academy Stadium'
WHERE venue_original IN (
    'Dr DY Patil Sports Academy',
    'Dr DY Patil Sports Academy, Mumbai'
);

-- updating Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium (Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium - Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium,Visakhapatnam)
UPDATE venue_dim
SET venue_standardized = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium'
WHERE venue_original IN (
    'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium',
    'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium, Visakhapatnam'
);

-- updating Eden Gardens ( Eden Gardens - Eden Gardens,Kolkata)
UPDATE venue_dim
SET venue_standardized = 'Eden Gardens'
WHERE venue_original IN (
    'Eden Gardens',
    'Eden Gardens, Kolkata'
);

-- updating Himachal Pradesh Cricket Association Stadium, Dharamsala(Himachal Pradesh Cricket Association Stadium-Himachal Pradesh Cricket Association Stadium, Dharamsala)
UPDATE venue_dim
SET venue_standardized = 'Himachal Pradesh Cricket Association Stadium, Dharamsala'
WHERE venue_original IN (
    'Himachal Pradesh Cricket Association Stadium',
    'Himachal Pradesh Cricket Association Stadium, Dharamsala'
);

-- updating M Chinnaswamy Stadium, Bengaluru
UPDATE venue_dim
SET venue_standardized = 'M Chinnaswamy Stadium, Bengaluru'
WHERE venue_original IN (
    'M Chinnaswamy Stadium',
    'M Chinnaswamy Stadium, Bengaluru',
    'M.Chinnaswamy Stadium'
);

-- updating MA Chidambaram Stadium, Chepauk, Chennai
UPDATE venue_dim
SET venue_standardized = 'MA Chidambaram Stadium, Chepauk, Chennai'
WHERE venue_original IN (
    'MA Chidambaram Stadium',
    'MA Chidambaram Stadium, Chepauk',
    'MA Chidambaram Stadium, Chepauk, Chennai'
);

-- updating Maharaja Yadavindra Singh International Cricket Stadium, Mullanpur
UPDATE venue_dim
SET venue_standardized = 'Maharaja Yadavindra Singh International Cricket Stadium, Mullanpur'
WHERE venue_original IN (
    'Maharaja Yadavindra Singh International Cricket Stadium, Mullanpur',
    'Maharaja Yadavindra Singh International Cricket Stadium, New Chandigarh'
);

-- updating Maharashtra Cricket Association Stadium, Pune
UPDATE venue_dim
SET venue_standardized = 'Maharashtra Cricket Association Stadium, Pune'
WHERE venue_original IN (
    'Maharashtra Cricket Association Stadium',
    'Maharashtra Cricket Association Stadium, Pune'
);

-- updating Punjab Cricket Association IS Bindra Stadium, Mohali
UPDATE venue_dim
SET venue_standardized = 'Punjab Cricket Association IS Bindra Stadium, Mohali'
WHERE venue_original IN (
    'Punjab Cricket Association IS Bindra Stadium',
    'Punjab Cricket Association IS Bindra Stadium, Mohali',
    'Punjab Cricket Association IS Bindra Stadium, Mohali, Chandigarh',
    'Punjab Cricket Association Stadium, Mohali'
);

-- updating Rajiv Gandhi International Stadium, Uppal, Hyderabad
UPDATE venue_dim
SET venue_standardized = 'Rajiv Gandhi International Stadium, Uppal, Hyderabad'
WHERE venue_original IN (
    'Rajiv Gandhi International Stadium',
    'Rajiv Gandhi International Stadium, Uppal',
    'Rajiv Gandhi International Stadium, Uppal, Hyderabad'
);

-- updating Sawai Mansingh Stadium, Jaipur
UPDATE venue_dim
SET venue_standardized = 'Sawai Mansingh Stadium, Jaipur'
WHERE venue_original IN (
    'Sawai Mansingh Stadium',
    'Sawai Mansingh Stadium, Jaipur'
);

-- updating Wankhede Stadium, Mumbai
UPDATE venue_dim
SET venue_standardized = 'Wankhede Stadium, Mumbai'
WHERE venue_original IN (
    'Wankhede Stadium',
    'Wankhede Stadium, Mumbai'
);

-- updating Zayed Cricket Stadium, Abu Dhabi
UPDATE venue_dim
SET venue_standardized = 'Zayed Cricket Stadium, Abu Dhabi'
WHERE venue_original IN (
    'Sheikh Zayed Stadium',
    'Zayed Cricket Stadium, Abu Dhabi'
);

UPDATE venue_dim
SET venue_standardized = 'Narendra Modi Stadium, Ahmedabad'
WHERE venue_original IN (
    'Sardar Patel Stadium, Motera',
    'Narendra Modi Stadium, Ahmedabad'
);


-- creating a team dim table
CREATE TABLE team_dim (
    team_original VARCHAR(100) PRIMARY KEY,
    team_standardized VARCHAR(100)
);

INSERT INTO team_dim (team_original, team_standardized)
SELECT DISTINCT batting_team, batting_team
FROM deliveries;

-- Royal Challengers rename
UPDATE team_dim
SET team_standardized = 'Royal Challengers Bengaluru'
WHERE team_original IN (
    'Royal Challengers Bangalore',
    'Royal Challengers Bengaluru'
);

-- Pune franchise rename
UPDATE team_dim
SET team_standardized = 'Rising Pune Supergiants'
WHERE team_original IN (
    'Rising Pune Supergiants',
    'Rising Pune Supergiant'
);

-- creating a view so that we can have the standardized names based for the further joins
CREATE VIEW matches_clean AS
SELECT 
    m.*,
    td.team_standardized AS match_winner_std
FROM matches m
LEFT JOIN team_dim td
    ON m.match_won_by = td.team_original;