/*
    This is a simple randomizer that complies with these points
    - Given number of result set row(s)
    - A count of number(s) inside a set
    - Parametized upper and lower limit range e.g. 1-10, 15-35
    - Take note of this (numbers inside a set) >= (Upper number limit) - (Lower number limit) 
    ** CALL sp_numberset_generator(<a>, <b>, <c>, <d>);

    For example, given is
    - 10 sets <a>
    - 6 numbers per set <b>
    - Numbers will start at 50 <c>
    - Until number 58 <d>

    Sample run @ MySQL 5.7    
    CALL sp_numberset_generator(8, 6, 1, 58);
*/
DROP PROCEDURE IF EXISTS `sp_numberset_generator`;
DELIMITER $$
CREATE PROCEDURE `sp_numberset_generator` (
    IN set_count BIGINT(20),
    IN digit_count TINYINT(1),
    IN digit_start TINYINT(2),
    IN digit_limit TINYINT(2)
) BEGIN
SET @set_count = `set_count`;
SET @digit_count = `digit_count`;
SET @digit_start = `digit_start`;
SET @digit_limit = `digit_limit`;
/*
Container
*/
-- process container
DROP TEMPORARY TABLE IF EXISTS `temp_number`;
CREATE TEMPORARY TABLE `temp_number` (`value` TINYINT(2) ZEROFILL);
-- output container
DROP TEMPORARY TABLE IF EXISTS `temp_result`;
CREATE TEMPORARY TABLE `temp_result` (result TEXT);
/*
Loop Value Generator
*/
-- set variable
SET @set_counter = 0;
-- processing set loop
loop_set: REPEAT
-- actual loop    
    SET @counter = 0;
    SET @input = 0;
/*
    INPUT PROCESSING
*/
    loop_generator: REPEAT
        -- re-initialize value generator counter
        SET @checker_count = 0;
        -- this part of the loop checks and creates the unique number
        loop_checker: REPEAT
            -- generate value for the instance, convert the decimat output of RAND() into a whole number
            SET @input = (FLOOR(RAND() * (@digit_limit - @digit_start + 1) + @digit_start));
            -- check if input value already exists in container
            SELECT COUNT(*) INTO @checker_count FROM `temp_number` WHERE value = @input;
            IF @checker_count = 0 AND (
                -- even number for an even roll
                (@counter % 2 = 0 AND @input % 2 = 0) 
                -- odd number for an odd roll
                OR (@counter % 2 != 0 AND @input % 2 != 0)
            ) THEN
                SET @checker_count = 0;
            ELSE
                SET @checker_count = 1;
            END IF;
        UNTIL @checker_count = 0    
        END REPEAT loop_checker;
        -- insert into container
        INSERT INTO `temp_number` (value)
        VALUES(@input);
        -- increment loop_generator counter
        SET @counter = @counter + 1;
    UNTIL @counter >= @digit_count
    END REPEAT loop_generator;
/*
    OUTPUT PROCESSING
*/
    -- place value into a container
    SELECT GROUP_CONCAT(value ORDER BY value ASC SEPARATOR ' - ') `result` 
    INTO @output
    FROM `temp_number`;
    -- check if set is existing in the collection
    SELECT COUNT(*) INTO @occurence
    FROM `temp_result` WHERE result = @output;
    -- decide if set will be recorded
    IF @occurence = 0 THEN
        -- output result
        INSERT INTO `temp_result` (result)
        VALUES (@output);
        -- increment the counter
        SET @set_counter = @set_counter + 1;
    END IF;
/*
    CLEANUP SET CONTAINER FOR EACH ROUND
*/
    -- cleanup temp container
    TRUNCATE TABLE `temp_number`;    
UNTIL @set_counter >= @set_count
END REPEAT loop_set;
/*
    FINAL OUTPUT / CLEANUP
*/
-- output
SELECT `result` FROM `temp_result`;
-- cleanup
DROP TEMPORARY TABLE IF EXISTS `temp_result`;
DROP TEMPORARY TABLE IF EXISTS `temp_number`;
END$$
DELIMITER ;