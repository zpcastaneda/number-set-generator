/*
	This is a simple randomizer that complies with these points
    - Number of Digits
    - Digit limit from 1 until given limit
    - Unique digit per set
    - Places the output inside an outgoing variable
    
    Sample run
    CALL sp_numberset_generator(6, 58, @lotto_result);
	SELECT @lotto_result;
*/
DROP PROCEDURE IF EXISTS `sp_numberset_generator`;
DELIMITER $$
CREATE PROCEDURE `sp_numberset_generator` (
	IN digit_count TINYINT(1),
    IN digit_limit TINYINT(2),
    OUT number_result VARCHAR(50)
) BEGIN
	SET @digit_count = `digit_count`;
    SET @digit_limit = `digit_limit`;    
/*
	Container
*/
	DROP TEMPORARY TABLE IF EXISTS `temp_number`;
    CREATE TEMPORARY TABLE `temp_number` (`value` TINYINT(2));
/*
	Loop Value Generator
*/
-- variables
	SET @counter = 0;
    SET @input = 0;
-- actual loop
    loop_generator: REPEAT
		-- re-initialize value generator counter
		SET @checker_count = 0;
		-- this part of the loop checks and creates the unique number
		loop_checker: REPEAT
			-- generate value for the instance
			SET @input = (SELECT CEIL(RAND() * (@digit_limit)));
            -- check if input value already exists in container
            SELECT COUNT(*) INTO @checker_count FROM `temp_number` WHERE value = @input;
        UNTIL @checker_count = 0    
		END REPEAT loop_checker;
        -- insert into container
        INSERT INTO `temp_number` (value)
        VALUES(@input);
        -- increment loop_generator counter
		SET @counter = @counter + 1;
    UNTIL @counter > @digit_count
    END REPEAT loop_generator;
    -- output result
    SELECT GROUP_CONCAT(value) `result` 
    INTO `number_result`
    FROM `temp_number`;
END$$
DELIMITER ;
