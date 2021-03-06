-- Function to return the term type given a subject id
-- It currently just returns the term type for the 
-- first term.
DROP FUNCTION IF EXISTS GetTermType;

DELIMITER $$

CREATE FUNCTION GetTermType(f_subject_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_term_type VARCHAR(255) DEFAULT "";	
	
	SELECT enumeration_value.`value` INTO f_term_type 
	FROM term 
	INNER JOIN enumeration_value 
	ON term.`term_type_id` = enumeration_value.`id` 
	WHERE term.`id`  
	IN (SELECT subject_term.`term_id` 
		FROM subject_term 
		WHERE subject_term.`subject_id` = f_subject_id)  
	LIMIT 1;
	
	RETURN f_term_type;
END $$

DELIMITER ;

-- Function to return the parent resource record id if 
-- resource, or archival_object id is passed in.
DROP FUNCTION IF EXISTS GetResourceId;

DELIMITER $$

CREATE FUNCTION GetResourceId(f_resource_id INT, f_archival_object_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_root_record_id INT;	
	
	IF f_resource_id IS NOT NULL THEN
		SET f_root_record_id = f_resource_id;
	ELSE
		SELECT archival_object.`root_record_id` INTO f_root_record_id 
		FROM archival_object 
		WHERE archival_object.`id` = f_archival_object_id;  
	END IF;
	
	RETURN f_root_record_id;
END $$

DELIMITER ;

-- Function to return the parent digital object record id if 
-- digital_object, or digital_object_component id is passed in.
DROP FUNCTION IF EXISTS GetDigitalObjectId;

DELIMITER $$

CREATE FUNCTION GetDigitalObjectId(f_digital_object_id INT, f_digital_component_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_root_record_id INT;	
	
	IF f_digital_object_id IS NOT NULL THEN
		SET f_root_record_id = f_digital_object_id;
	ELSE
		SELECT digital_object_component.`root_record_id` INTO f_root_record_id 
		FROM digital_object_component 
		WHERE digital_object_component.`id` = f_digital_component_id;  
	END IF;
	
	RETURN f_root_record_id;
END $$

DELIMITER ;

-- Function to return a coordinate string by concating the three 
-- coordinate labels and indicators
DROP FUNCTION IF EXISTS GetCoordinate;

DELIMITER $$

CREATE FUNCTION GetCoordinate(f_location_id INT) 
	RETURNS VARCHAR(1020)
	READS SQL DATA
BEGIN
	DECLARE f_coordinate VARCHAR(1020);	
        DECLARE f_coordinate_1 VARCHAR(255);
        DECLARE f_coordinate_2 VARCHAR(255);
        DECLARE f_coordinate_3 VARCHAR(255);
        
        -- The three select statements can be combined into 1 query, but for clarity 
        -- are left separate
	SELECT CONCAT(location.`coordinate_1_label`, ' ', location.`coordinate_1_indicator`)  
                INTO f_coordinate_1 
		FROM location 
		WHERE location.`id` = f_location_id;
	
        SELECT CONCAT(location.`coordinate_2_label`, ' ', location.`coordinate_2_indicator`)  
                INTO f_coordinate_2 
		FROM location 
		WHERE location.`id` = f_location_id;

        SELECT CONCAT(location.`coordinate_3_label`, ' ', location.`coordinate_3_indicator`)  
                INTO f_coordinate_3 
		FROM location 
		WHERE location.`id` = f_location_id; 
        
        SET f_coordinate = CONCAT_WS('/', f_coordinate_1, f_coordinate_2, f_coordinate_3);
        
	RETURN f_coordinate;
END $$

DELIMITER ;


-- Function to return enum value given an id
DROP FUNCTION IF EXISTS GetEnumValue;

DELIMITER $$

CREATE FUNCTION GetEnumValue(f_enum_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT enumeration_value.`value`INTO f_value
	FROM enumeration_value
	WHERE enumeration_value.`id` = f_enum_id;
	    
	RETURN f_value;
END $$

DELIMITER ;


-- Function to return the enum value with the first letter capitalize
DROP FUNCTION IF EXISTS GetEnumValueUF;

DELIMITER $$

CREATE FUNCTION GetEnumValueUF(f_enum_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	DECLARE f_ovalue VARCHAR(255);
        
        SET f_ovalue = GetEnumValue(f_enum_id);
	SET f_value = CONCAT(UCASE(LEFT(f_ovalue, 1)), SUBSTRING(f_ovalue, 2));
	    
	RETURN f_value;
END $$

DELIMITER ;


-- Function to return the number of resources for a particular repository
DROP FUNCTION IF EXISTS GetTotalResources;

DELIMITER $$

CREATE FUNCTION GetTotalResources(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM resource 
	WHERE resource.`repo_id` = f_repo_id;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of resources with level = item for a 
-- particular repository
DROP FUNCTION IF EXISTS GetTotalResourcesItems;

DELIMITER $$

CREATE FUNCTION GetTotalResourcesItems(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM resource 
	WHERE (resource.`repo_id` = f_repo_id
	AND 
	BINARY GetEnumValue(resource.`level_id`) = BINARY 'item');
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of resources with restrictions for a 
-- particular repository
DROP FUNCTION IF EXISTS GetResourcesWithRestrictions;

DELIMITER $$

CREATE FUNCTION GetResourcesWithRestrictions(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM resource 
	WHERE (resource.`repo_id` = f_repo_id
	AND 
	resource.`restrictions` = 1);
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of resources with finding aids for a 
-- particular repository
DROP FUNCTION IF EXISTS GetResourcesWithFindingAids;

DELIMITER $$

CREATE FUNCTION GetResourcesWithFindingAids(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM resource 
	WHERE (resource.`repo_id` = f_repo_id
	AND 
	resource.`ead_id` IS NOT NULL);
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of accessions for a particular repository
DROP FUNCTION IF EXISTS GetTotalAccessions;

DELIMITER $$

CREATE FUNCTION GetTotalAccessions(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM accession 
	WHERE accession.`repo_id` = f_repo_id;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of accessions that are processed for
-- a particular repository
DROP FUNCTION IF EXISTS GetAccessionsProcessed;

DELIMITER $$

CREATE FUNCTION GetAccessionsProcessed(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT count(T1.id) INTO f_total  
	FROM 
            event_link_rlshp T1
	INNER JOIN 
            event T2 ON T1.event_id = T2.id 
	WHERE (
            T2.repo_id = f_repo_id
        AND
            T1.accession_id IS NOT NULL
	AND 
            BINARY GetEnumValue(T2.event_type_id) = BINARY 'processed');
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return if an accessions has been processed
DROP FUNCTION IF EXISTS GetAccessionProcessed;

DELIMITER $$

CREATE FUNCTION GetAccessionProcessed(f_accession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT T1.event_id INTO f_value  
	FROM 
            event_link_rlshp T1 
	INNER JOIN 
            event T2 ON T1.event_id = T2.id 
	WHERE 
            (T1.accession_id = f_accession_id  
	AND 
            BINARY GetEnumValue(T2.event_type_id) = BINARY 'processed')
        LIMIT 1;
	    
	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to return the process date for a particular accession
DROP FUNCTION IF EXISTS GetAccessionProcessedDate;

DELIMITER $$

CREATE FUNCTION GetAccessionProcessedDate(f_accession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT GetEventDateExpression(T1.event_id) INTO f_value  
	FROM 
            event_link_rlshp T1 
	INNER JOIN 
            event T2 ON T1.event_id = T2.id 
	WHERE 
            (T1.accession_id = f_accession_id  
	AND 
            BINARY GetEnumValue(T2.event_type_id) = BINARY 'processed')
        LIMIT 1;
	    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the processing started date for a particular accession
DROP FUNCTION IF EXISTS GetAccessionProcessingStartedDate;

DELIMITER $$

CREATE FUNCTION GetAccessionProcessingStartedDate(f_accession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT GetEventDateExpression(T1.event_id) INTO f_value  
	FROM 
            event_link_rlshp T1 
	INNER JOIN 
            event T2 ON T1.event_id = T2.id 
	WHERE 
            (T1.accession_id = f_accession_id  
	AND 
            BINARY GetEnumValue(T2.event_type_id) = BINARY 'processing_started')
        LIMIT 1;
	    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the number of accessions that are cataloged for
-- a particular repository
DROP FUNCTION IF EXISTS GetAccessionsCataloged;

DELIMITER $$

CREATE FUNCTION GetAccessionsCataloged(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT count(T2.accession_id) INTO f_total  
	FROM 
            event T1 
	INNER JOIN 
            event_link_rlshp T2 ON T1.id = T2.event_id 
	WHERE (
            T1.repo_id = f_repo_id  
	AND 
            T2.accession_id IS NOT NULL 
	AND 
            BINARY GetEnumValue(T1.event_type_id) = BINARY 'cataloged')
        LIMIT 1;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the if an accessions has been cataloged
DROP FUNCTION IF EXISTS GetAccessionCataloged;

DELIMITER $$

CREATE FUNCTION GetAccessionCataloged(f_accession_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;	
	
	SELECT T1.id INTO f_value 
	FROM 
            event T1 
	INNER JOIN 
            event_link_rlshp T2 ON T1.id = T2.event_id 
	WHERE (
            T2.accession_id = f_accession_id 
	AND 
            BINARY GetEnumValue(T1.event_type_id) = BINARY 'cataloged')
        LIMIT 1;

	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to return the process date for a particular accession
DROP FUNCTION IF EXISTS GetAccessionCatalogedDate;

DELIMITER $$

CREATE FUNCTION GetAccessionCatalogedDate(f_accession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT GetEventDateExpression(T1.event_id) INTO f_value  
	FROM 
            event_link_rlshp T1 
	INNER JOIN 
            event T2 ON T1.event_id = T2.id 
	WHERE 
            (T1.accession_id = f_accession_id  
	AND 
            BINARY GetEnumValue(T2.event_type_id) = BINARY 'cataloged')
        LIMIT 1;
	    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the number of accessions with restrictions for a 
-- particular repository
DROP FUNCTION IF EXISTS GetAccessionsWithRestrictions;

DELIMITER $$

CREATE FUNCTION GetAccessionsWithRestrictions(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM accession 
	WHERE (accession.`repo_id` = f_repo_id
	AND 
	accession.`use_restrictions` = 1);
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of accessions that have had rights transferred
-- for a particular repository
DROP FUNCTION IF EXISTS GetAccessionsWithRightsTransferred;

DELIMITER $$

CREATE FUNCTION GetAccessionsWithRightsTransferred(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT count(T2.accession_id) INTO f_total  
	FROM 
            event T1 
	INNER JOIN 
            event_link_rlshp T2 ON T1.id = T2.event_id 
	WHERE ( 
            T1.repo_id = f_repo_id  
	AND 
            T2.accession_id IS NOT NULL 
	AND 
            BINARY GetEnumValue(T1.event_type_id) = BINARY 'rights_transferred');
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return if an accession has had it's rights transferred
DROP FUNCTION IF EXISTS GetAccessionRightsTransferred;

DELIMITER $$

CREATE FUNCTION GetAccessionRightsTransferred(f_accession_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;	
	
	SELECT T1.id INTO f_value  
	FROM 
            event T1 
	INNER JOIN 
            event_link_rlshp T2 ON T1.id = T2.event_id 
	WHERE 
            T2.accession_id = f_accession_id 
	AND 
            BINARY GetEnumValue(T1.event_type_id) = BINARY 'rights_transferred';
	    
	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to return if  acknowlegement has been set for accession
DROP FUNCTION IF EXISTS GetAccessionAcknowledgementSent;

DELIMITER $$

CREATE FUNCTION GetAccessionAcknowledgementSent(f_accession_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;	
	
	SELECT T1.id INTO f_value  
	FROM 
            event T1 
	INNER JOIN 
            event_link_rlshp T2 ON T1.id = T2.event_id 
	WHERE 
            T2.accession_id = f_accession_id 
	AND 
            BINARY GetEnumValue(T1.event_type_id) = BINARY 'acknowledgement_sent';
	    
	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to return if an accession has had it's rights transferred
DROP FUNCTION IF EXISTS GetAccessionRightsTransferredNote;

DELIMITER $$

CREATE FUNCTION GetAccessionRightsTransferredNote(f_accession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT T1.outcome_note INTO f_value  
	FROM 
            event T1 
	INNER JOIN 
            event_link_rlshp T2 ON T1.id = T2.event_id 
	WHERE 
            T2.accession_id = f_accession_id 
	AND 
            BINARY GetEnumValue(T1.event_type_id) = BINARY 'rights_transferred';

	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the date expression for an event
DROP FUNCTION IF EXISTS GetEventDateExpression;

DELIMITER $$

CREATE FUNCTION GetEventDateExpression(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        DECLARE f_date VARCHAR(255);
        DECLARE f_expression VARCHAR(255);
        DECLARE f_begin VARCHAR(255);
        DECLARE f_end VARCHAR(255);
	
	SELECT date.`expression`, date.`begin`, date.`end` 
        INTO f_expression, f_begin, f_end 
	FROM 
            date 
	WHERE date.`event_id` = f_record_id 
        LIMIT 1;
	
        -- If the expression is null return the concat of begin and end
        SET f_date = CONCAT(f_begin, '-', f_end);
        
        IF f_expression IS NULL THEN
            SET f_value = f_date;
        ELSEIF f_date IS NOT NULL THEN
            SET f_value = CONCAT(f_expression, ' , ', f_date);
        ELSE
            SET f_value = f_expression;
        END IF;
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the number of personal agent records
DROP FUNCTION IF EXISTS GetAgentsPersonal;

DELIMITER $$

CREATE FUNCTION GetAgentsPersonal(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM agent_person
	WHERE agent_person.`id` NOT IN (
		SELECT user.`agent_record_id` 
		FROM
		user WHERE 
		user.`agent_record_id` IS NOT NULL);
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of corporate agent records
DROP FUNCTION IF EXISTS GetAgentsCorporate;

DELIMITER $$

CREATE FUNCTION GetAgentsCorporate(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM agent_corporate_entity 
	WHERE agent_corporate_entity.`publish` IS NOT NULL;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of family agent records
DROP FUNCTION IF EXISTS GetAgentsFamily;

DELIMITER $$

CREATE FUNCTION GetAgentsFamily(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM agent_family;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of software agent records
DROP FUNCTION IF EXISTS GetAgentsSoftware;

DELIMITER $$

CREATE FUNCTION GetAgentsSoftware(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM agent_software
	WHERE agent_software.`system_role` = 'none';
	    
	RETURN f_total;
END $$

DELIMITER ;


-- Function to return the agent type i.e. Person, Family, Corporate, Software
-- when those ids found in the linked_agents_rlshp are passed in as parameters
DROP FUNCTION IF EXISTS GetAgentMatch;

DELIMITER $$

CREATE FUNCTION GetAgentMatch(f_agent_type VARCHAR(10), f_agent_id INT, 
                              f_person_id INT, f_family_id INT, f_corporate_id INT, f_software_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_agent_match INT;	
	
	IF f_agent_type = 'Person' AND f_person_id = f_agent_id THEN
            SET f_agent_match = 1;
        ELSEIF f_agent_type = 'Family' AND f_family_id = f_agent_id THEN
            SET f_agent_match = 1;
        ELSEIF f_agent_type = 'Corporate' AND f_corporate_id = f_agent_id THEN
            SET f_agent_match = 1;
        ELSEIF f_agent_type = 'Software' AND f_software_id = f_agent_id THEN
            SET f_agent_match = 1;
        ELSE 
            SET f_agent_match = 0;
        END IF;

	RETURN f_agent_match;
END $$

DELIMITER ; 

-- Function to return the sortname given a Person, Family, or Corporate
-- when those ids found in the linked_agents_rlshp are passed in as parameters
DROP FUNCTION IF EXISTS GetAgentSortName;

DELIMITER $$

CREATE FUNCTION GetAgentSortName(f_person_id INT, f_family_id INT, f_corporate_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	IF f_person_id IS NOT NULL THEN
            SELECT sort_name INTO f_value FROM name_person WHERE agent_person_id = f_person_id LIMIT 1;
        ELSEIF f_family_id IS NOT NULL THEN
            SELECT sort_name INTO f_value FROM name_family WHERE agent_family_id = f_family_id LIMIT 1;
        ELSEIF f_corporate_id IS NOT NULL THEN
            SELECT sort_name INTO f_value FROM name_corporate_entity WHERE agent_corporate_entity_id = f_corporate_id LIMIT 1;
        ELSE 
            SET f_value = 'Unknown';
        END IF;

	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the sortname given a Person, Family, or Corporate + the role Id
-- when those ids found in the linked_agents_rlshp are passed in as parameters
DROP FUNCTION IF EXISTS GetAgentUniqueName;

DELIMITER $$

CREATE FUNCTION GetAgentUniqueName(f_person_id INT, f_family_id INT, f_corporate_id INT, f_role_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	IF f_person_id IS NOT NULL THEN
            SELECT sort_name INTO f_value FROM name_person WHERE agent_person_id = f_person_id LIMIT 1;
        ELSEIF f_family_id IS NOT NULL THEN
            SELECT sort_name INTO f_value FROM name_family WHERE agent_family_id = f_family_id LIMIT 1;
        ELSEIF f_corporate_id IS NOT NULL THEN
            SELECT sort_name INTO f_value FROM name_corporate_entity WHERE agent_corporate_entity_id = f_corporate_id LIMIT 1;
        ELSE 
            SET f_value = 'Unknown';
        END IF;

	RETURN CONCAT_WS('-',f_value, f_role_id);
END $$

DELIMITER ;

-- Function to return if a resource record has any agents linked to it has
-- Creators
DROP FUNCTION IF EXISTS GetResourceHasCreator;

DELIMITER $$

CREATE FUNCTION GetResourceHasCreator(f_record_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;	
        
        SELECT
            T1.`id` INTO f_value
        FROM
            `linked_agents_rlshp` T1
        WHERE
            GetResourceId(T1.`resource_id`, T1.`archival_object_id`) = f_record_id
        AND
            BINARY GetEnumValue(T1.`role_id`) = BINARY 'creator'
        LIMIT 1;

	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to any agents sort_name linked to the resource has
-- Creators
DROP FUNCTION IF EXISTS GetResourceCreator;

DELIMITER $$

CREATE FUNCTION GetResourceCreator(f_record_id INT) 
	RETURNS VARCHAR(1024)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(1024);	
        
        SELECT
            GROUP_CONCAT(GetAgentSortname(T1.`agent_person_id`, T1.`agent_family_id`, T1.`agent_corporate_entity_id`) SEPARATOR '; ') INTO f_value
        FROM
            `linked_agents_rlshp` T1
        WHERE
            GetResourceId(T1.`resource_id`, T1.`archival_object_id`) = f_record_id
        AND
            BINARY GetEnumValue(T1.`role_id`) = BINARY 'creator';

	RETURN f_value;
END $$

DELIMITER ;

-- Function to return if a resource record has any agents linked to it has
-- Source
DROP FUNCTION IF EXISTS GetResourceHasSource;

DELIMITER $$

CREATE FUNCTION GetResourceHasSource(f_record_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;	
        
        SELECT
            T1.`id` INTO f_value
        FROM
            `linked_agents_rlshp` T1
        WHERE
            GetResourceId(T1.`resource_id`, T1.`archival_object_id`) = f_record_id
        AND
            BINARY GetEnumValue(T1.`role_id`) = BINARY 'source' 
        LIMIT 1;

	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to return if a resource record has any agents linked to it has
-- Creators
DROP FUNCTION IF EXISTS GetResourceHasDeaccession;

DELIMITER $$

CREATE FUNCTION GetResourceHasDeaccession(f_record_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;	
        
        SELECT
            T1.`id` INTO f_value
        FROM
            `deaccession` T1
        WHERE
            T1.`resource_id` = f_record_id
        LIMIT 1;

	RETURN GetBoolean(f_value);
END $$

DELIMITER ;

-- Function to return the number of subject records
DROP FUNCTION IF EXISTS GetTotalSubjects;

DELIMITER $$

CREATE FUNCTION GetTotalSubjects(f_repo_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM subject;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of resource records for a particular finding
-- aid status
DROP FUNCTION IF EXISTS GetStatusCount;

DELIMITER $$

CREATE FUNCTION GetStatusCount(f_repo_id INT, f_status_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM 
		resource
	WHERE 
		resource.`finding_aid_status_id` = f_status_id
		AND
		resource.`repo_id` = f_repo_id;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of resource records for a particular language
-- code
DROP FUNCTION IF EXISTS GetLanguageCount;

DELIMITER $$

CREATE FUNCTION GetLanguageCount(f_repo_id INT, f_language_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT;	
	
	SELECT COUNT(id) INTO f_total 
	FROM 
		resource
	WHERE 
		resource.`language_id` = f_language_id
		AND
		resource.`repo_id` = f_repo_id;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of instances for a particular instance type 
-- in a repository. I couldn't find a simpler way to do this counting
DROP FUNCTION IF EXISTS GetInstanceCount;

DELIMITER $$

CREATE FUNCTION GetInstanceCount(f_repo_id INT, f_instance_type_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT DEFAULT 0;
	DECLARE f_id INT;	
	DECLARE done INT DEFAULT 0;
	
	DECLARE cur CURSOR FOR SELECT T1.`id`  
	FROM 
            resource T1
	INNER JOIN
            instance T2 ON GetResourceId(T2.`resource_id`, T2.`archival_object_id`) = T1.`id`
        WHERE 
            T1.`repo_id` = f_repo_id
	AND
            T2.`instance_type_id` = f_instance_type_id 
	GROUP BY
            T1.`id`;	
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	OPEN cur;
	
	count_resource: LOOP
            FETCH cur INTO f_id;
	
            IF done = 1 THEN
		LEAVE count_resource;
            END IF;
		
            SET f_total = f_total + 1;
	
	END LOOP count_resource;
	
	CLOSE cur;
	    
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the total extent of unprocessed accessions that
-- for a particular repository
DROP FUNCTION IF EXISTS GetAccessionsExtent;

DELIMITER $$

CREATE FUNCTION GetAccessionsExtent(f_repo_id INT, f_extent_type_id INT) 
	RETURNS DECIMAL(10,2)
	READS SQL DATA
BEGIN
	DECLARE f_total DECIMAL(10,2);	
	
	SELECT SUM(T1.number) INTO f_total  
	FROM extent T1 
	INNER JOIN 
		accession T2 ON T1.accession_id = T2.id 
	WHERE (T2.repo_id = f_repo_id   
		AND GetAccessionCataloged(T2.id) = 0
		AND T1.extent_type_id = f_extent_type_id);
	
	-- Check for null then set it to zero
	IF f_total IS NULL THEN
		SET f_total = 0;
	END IF;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the total extent for an accession record
DROP FUNCTION IF EXISTS GetAccessionExtent;

DELIMITER $$

CREATE FUNCTION GetAccessionExtent(f_accession_id INT) 
	RETURNS DECIMAL(10,2)
	READS SQL DATA
BEGIN
	DECLARE f_total DECIMAL(10,2);	
	
	SELECT 
            SUM(T1.number) INTO f_total  
	FROM 
            extent T1
	WHERE 
            T1.accession_id = f_accession_id;
	
	-- Check for null then set it to zero
	IF f_total IS NULL THEN
            SET f_total = 0;
	END IF;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the accession extent type
DROP FUNCTION IF EXISTS GetAccessionExtentType;

DELIMITER $$

CREATE FUNCTION GetAccessionExtentType(f_accession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT 
            GetEnumValueUF(T1.extent_type_id) INTO f_value  
	FROM 
            extent T1 
	WHERE 
            T1.accession_id = f_accession_id
        LIMIT 1;
	
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the accession container summary
DROP FUNCTION IF EXISTS GetAccessionContainerSummary;

DELIMITER $$

CREATE FUNCTION GetAccessionContainerSummary(f_accession_id INT) 
	RETURNS TEXT
	READS SQL DATA
BEGIN
	DECLARE f_value TEXT;	
	
	SELECT T1.container_summary INTO f_value  
	FROM extent T1 
	WHERE T1.accession_id = f_accession_id
        LIMIT 1;
	
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the accession id for a given instance
DROP FUNCTION IF EXISTS GetAccessionIdForInstance;

DELIMITER $$

CREATE FUNCTION GetAccessionIdForInstance(f_record_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;
        
        -- get the resource id 
	SELECT T1.`accession_id` INTO f_value  
	FROM 
            instance T1
	WHERE T1.`id` = f_record_id; 
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the total extent of resources and its' archival objects
-- for a particular repository
DROP FUNCTION IF EXISTS GetResourcesExtent;

DELIMITER $$

CREATE FUNCTION GetResourcesExtent(f_repo_id INT, f_extent_type_id INT) 
	RETURNS DECIMAL(10,2)
	READS SQL DATA
BEGIN
	DECLARE f_total DECIMAL(10,2);	
	
	SELECT 
            SUM(T1.number) INTO f_total  
	FROM 
            extent T1 
	INNER JOIN 
            resource T2 ON GetResourceId(T1.resource_id, T1.archival_object_id) = T2.id 
	WHERE 
            (T2.repo_id = f_repo_id AND T1.extent_type_id = f_extent_type_id);
	
	-- Check for null then set it to zero
	IF f_total IS NULL THEN
		SET f_total = 0;
	END IF;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the total extent of a resource record excluding the
-- archival objects
DROP FUNCTION IF EXISTS GetResourceExtent;

DELIMITER $$

CREATE FUNCTION GetResourceExtent(f_resource_id INT) 
	RETURNS DECIMAL(10,2)
	READS SQL DATA
BEGIN
	DECLARE f_total DECIMAL(10,2);	
	
	SELECT 
            SUM(T1.number) INTO f_total  
	FROM 
            extent T1 
	WHERE 
            T1.resource_id = f_resource_id;
	
	-- Check for null then set it to zero
	IF f_total IS NULL THEN
            SET f_total = 0;
	END IF;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the resource extent type of a resource record excluding the
-- archival objects
DROP FUNCTION IF EXISTS GetResourceExtentType;

DELIMITER $$

CREATE FUNCTION GetResourceExtentType(f_resource_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT GetEnumValueUF(T1.extent_type_id) INTO f_value  
	FROM extent T1 
	WHERE T1.resource_id = f_resource_id
        LIMIT 1;
	
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the resource extent type of a resource record excluding the
-- archival objects
DROP FUNCTION IF EXISTS GetResourceContainerSummary;

DELIMITER $$

CREATE FUNCTION GetResourceContainerSummary(f_resource_id INT) 
	RETURNS TEXT
	READS SQL DATA
BEGIN
	DECLARE f_value TEXT;	
	
	SELECT T1.container_summary INTO f_value  
	FROM extent T1 
	WHERE T1.resource_id = f_resource_id
        LIMIT 1;
	
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the total extent of a resource record excluding the
-- archival objects
DROP FUNCTION IF EXISTS GetResourceDeaccessionExtent;

DELIMITER $$

CREATE FUNCTION GetResourceDeaccessionExtent(f_resource_id INT) 
	RETURNS DECIMAL(10,2)
	READS SQL DATA
BEGIN
	DECLARE f_total DECIMAL(10,2);	
	
	SELECT 
            SUM(T2.number) INTO f_total  
	FROM 
            deaccession T1
        INNER JOIN 
            extent T2 ON T1.id = T2.deaccession_id 
	WHERE 
            T1.resource_id = f_resource_id;
	
	-- Check for null then set it to zero
	IF f_total IS NULL THEN
            SET f_total = 0;
	END IF;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the number of subject records with a certain term type
DROP FUNCTION IF EXISTS GetTermTypeCount;

DELIMITER $$

CREATE FUNCTION GetTermTypeCount(f_term_type_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_total INT DEFAULT 0;	
	
        SELECT COUNT(*) INTO f_total
        FROM (
            SELECT T1.`id`
            FROM 
                term T1
            INNER JOIN
                subject_term T2 ON T1.`id` = T2.`term_id`
            WHERE
		T1.`term_type_id` = f_term_type_id
            GROUP BY 
                T2.`subject_id`
        ) AS t;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the date expression for an accession record
DROP FUNCTION IF EXISTS GetAccessionDateExpression;

DELIMITER $$

CREATE FUNCTION GetAccessionDateExpression(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        DECLARE f_date VARCHAR(255);
        DECLARE f_expression VARCHAR(255);
        DECLARE f_begin VARCHAR(255);
        DECLARE f_end VARCHAR(255);
	
	SELECT date.`expression`, date.`begin`, date.`end` 
        INTO f_expression, f_begin, f_end 
	FROM 
            date 
	WHERE date.`accession_id` = f_record_id 
        LIMIT 1;
	
        -- If the expression is null return the concat of begin and end
        SET f_date = CONCAT(f_begin, '-', f_end);
        
        IF f_expression IS NULL THEN
            SET f_value = f_date;
        ELSEIF f_date IS NOT NULL THEN
            SET f_value = CONCAT(f_expression, ' , ', f_date);
        ELSE
            SET f_value = f_expression;
        END IF;
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return a particula part of a date record for an accession record
-- f_part = 0 return date expression
-- f_part = 1 return date begin
-- f_part = 2 return date end
DROP FUNCTION IF EXISTS GetAccessionDatePart;

DELIMITER $$

CREATE FUNCTION GetAccessionDatePart(f_record_id INT, f_date_type VARCHAR(255), f_part INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        DECLARE f_expression VARCHAR(255);
        DECLARE f_begin VARCHAR(255);
        DECLARE f_end VARCHAR(255);
	
	SELECT 
            date.`expression`, date.`begin`, date.`end` 
        INTO 
            f_expression, f_begin, f_end 
	FROM 
            date 
	WHERE (
            date.`accession_id` = f_record_id
            AND
            GetEnumValue(date.`date_type_id`) = f_date_type)
        LIMIT 1;
	
        -- return the part we need
        IF f_part = 0 THEN
            SET f_value = f_expression;
        ELSEIF f_part = 1 THEN
            SET f_value = f_begin;
        ELSE
            SET f_value = f_end;
        END IF;
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the date expression for a digital object
DROP FUNCTION IF EXISTS GetDigitalObjectDateExpression;

DELIMITER $$

CREATE FUNCTION GetDigitalObjectDateExpression(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        DECLARE f_date VARCHAR(255);
        DECLARE f_expression VARCHAR(255);
        DECLARE f_begin VARCHAR(255);
        DECLARE f_end VARCHAR(255);
	
	SELECT date.`expression`, date.`begin`, date.`end` 
        INTO f_expression, f_begin, f_end 
	FROM 
            date 
	WHERE date.`digital_object_id` = f_record_id
        LIMIT 1;
	
        -- If the expression is null return the concat of begin and end
        SET f_date = CONCAT(f_begin, '-', f_end);
        
        IF f_expression IS NULL THEN
            SET f_value = f_date;
        ELSEIF f_date IS NOT NULL THEN
            SET f_value = CONCAT(f_expression, ' , ', f_date);
        ELSE
            SET f_value = f_expression;
        END IF;
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the date expression for a resource record
DROP FUNCTION IF EXISTS GetResourceDateExpression;

DELIMITER $$

CREATE FUNCTION GetResourceDateExpression(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        DECLARE f_date VARCHAR(255);
        DECLARE f_expression VARCHAR(255);
        DECLARE f_begin VARCHAR(255);
        DECLARE f_end VARCHAR(255);
	
	SELECT date.`expression`, date.`begin`, date.`end` 
        INTO f_expression, f_begin, f_end 
	FROM 
            date 
	WHERE date.`resource_id` = f_record_id 
        LIMIT 1;
	
        -- If the expression is null return the concat of begin and end
        SET f_date = CONCAT(f_begin, '-', f_end);
        
        IF f_expression IS NULL THEN
            SET f_value = f_date;
        ELSEIF f_date IS NOT NULL THEN
            SET f_value = CONCAT(f_expression, ' , ', f_date);
        ELSE
            SET f_value = f_expression;
        END IF;
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the resource id for a given instance
DROP FUNCTION IF EXISTS GetResourceIdForInstance;

DELIMITER $$

CREATE FUNCTION GetResourceIdForInstance(f_record_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;
        
        -- get the resource id 
	SELECT GetResourceID(T1.`resource_id`, T1.`archival_object_id`) INTO f_value  
	FROM 
            instance T1
	WHERE T1.`id` = f_record_id; 
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the resource identifier for a given instance
DROP FUNCTION IF EXISTS GetResourceIdentiferForInstance;

DELIMITER $$

CREATE FUNCTION GetResourceIdentiferForInstance(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        
        -- get the resource id 
	SELECT T2.`identifier` INTO f_value  
	FROM 
            instance T1
        INNER JOIN
            resource T2 ON GetResourceID(T1.`resource_id`, T1.`archival_object_id`) = T2.`id`
	WHERE T1.`id` = f_record_id; 
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the resource id (PK) for a given instance
DROP FUNCTION IF EXISTS GetResourceIdForInstance;

DELIMITER $$

CREATE FUNCTION GetResourceIdForInstance(f_record_id INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
	DECLARE f_value INT;
        
        -- get the resource id 
	SELECT 
            T2.`id` INTO f_value  
	FROM 
            instance T1
        INNER JOIN
            resource T2 ON GetResourceID(T1.`resource_id`, T1.`archival_object_id`) = T2.`id`
	WHERE 
            T1.`id` = f_record_id; 
    
	RETURN f_value;
END $$

DELIMITER ;


-- Function to return the resource identifier for a given instance
DROP FUNCTION IF EXISTS GetResourceTitleForInstance;

DELIMITER $$

CREATE FUNCTION GetResourceTitleForInstance(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        
        -- get the resource id 
	SELECT 
            T2.`title` INTO f_value  
	FROM 
            instance T1
        INNER JOIN
            resource T2 ON GetResourceID(T1.`resource_id`, T1.`archival_object_id`) = T2.`id`
	WHERE 
            T1.`id` = f_record_id; 
    
	RETURN f_value;
END $$

DELIMITER ;

-- function to return a 0 or 1 to represent a boolean value to the report
DROP FUNCTION IF EXISTS GetBoolean;

DELIMITER $$

CREATE FUNCTION GetBoolean(f_value INT) 
	RETURNS INT
	READS SQL DATA
BEGIN
    DECLARE f_boolean INT;
        
    IF f_value IS NULL THEN
        SET f_boolean = 0;
    ELSE 
        SET f_boolean = 1;
    END IF;

    RETURN f_boolean;
END $$

DELIMITER ;

-- function to return the name of a repository given the id
DROP FUNCTION IF EXISTS GetRepositoryName;

DELIMITER $$

CREATE FUNCTION GetRepositoryName(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
    DECLARE f_value VARCHAR(255);

    SELECT 
        `name` INTO f_value  
    FROM 
        repository 
    WHERE 
        `id` = f_record_id; 
    
    RETURN f_value;
END $$

DELIMITER ;

-- Function to return the date expression for an accession record
DROP FUNCTION IF EXISTS GetDeaccessionDate;

DELIMITER $$

CREATE FUNCTION GetDeaccessionDate(f_record_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);
        DECLARE f_expression VARCHAR(255);
        DECLARE f_begin VARCHAR(255);
	
	SELECT date.`expression`, date.`begin`
        INTO f_expression, f_begin
	FROM 
            date 
	WHERE date.`deaccession_id` = f_record_id 
        LIMIT 1;
	
        -- Just return the date begin       
        SET f_value = f_begin;
    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return the total extent for an deaccession record
DROP FUNCTION IF EXISTS GetDeaccessionExtent;

DELIMITER $$

CREATE FUNCTION GetDeaccessionExtent(f_deaccession_id INT) 
	RETURNS DECIMAL(10,2)
	READS SQL DATA
BEGIN
	DECLARE f_total DECIMAL(10,2);	
	
	SELECT 
            SUM(T1.number) INTO f_total  
	FROM 
            extent T1 
	WHERE 
            T1.deaccession_id = f_deaccession_id;
	
	-- Check for null then set it to zero
	IF f_total IS NULL THEN
            SET f_total = 0;
	END IF;
	
	RETURN f_total;
END $$

DELIMITER ;

-- Function to return the deaccession extent type
DROP FUNCTION IF EXISTS GetDeaccessionExtentType;

DELIMITER $$

CREATE FUNCTION GetDeaccessionExtentType(f_deaccession_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT 
            GetEnumValueUF(T1.extent_type_id) INTO f_value  
	FROM 
            extent T1 
	WHERE 
            T1.deaccession_id = f_deaccession_id
        LIMIT 1;
	
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return phone number given an agent contact id
DROP FUNCTION IF EXISTS GetPhoneNumber;

DELIMITER $$

CREATE FUNCTION GetPhoneNumber(f_agent_contact_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT 
            telephone.`number`INTO f_value
	FROM 
            telephone
	WHERE 
            telephone.`agent_contact_id` = f_agent_contact_id
            AND
            BINARY GetEnumValue(telephone.`number_type_id`) != BINARY 'fax'
        LIMIT 1;
	    
	RETURN f_value;
END $$

DELIMITER ;

-- Function to return fax number given an agent contact id
DROP FUNCTION IF EXISTS GetFaxNumber;

DELIMITER $$

CREATE FUNCTION GetFaxNumber(f_agent_contact_id INT) 
	RETURNS VARCHAR(255)
	READS SQL DATA
BEGIN
	DECLARE f_value VARCHAR(255);	
	
	SELECT 
            telephone.`number`INTO f_value
	FROM 
            telephone
	WHERE 
            telephone.`agent_contact_id` = f_agent_contact_id
            AND
            BINARY GetEnumValue(telephone.`number_type_id`) = BINARY 'fax'
        LIMIT 1;
	    
	RETURN f_value;
END $$

DELIMITER ;
