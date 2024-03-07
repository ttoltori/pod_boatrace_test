DROP FUNCTION IF EXISTS copyto_rank_result (VARCHAR(200));
CREATE OR REPLACE FUNCTION copyto_rank_result (
paramDir VARCHAR(200)
) RETURNS VOID AS $$
  DECLARE
    cumodel refcursor; -- 모델번호 커서
    recmodel record; -- 모델번호 레코드
    filepath varchar(200);
  BEGIN
	open cumodel for
	  select 
	    distinct description 
	    from  rank_result
	    order by description;
	
	loop
		fetch cumodel into recmodel;
		
		filepath := paramDir || 'rank_result_' || recmodel.description || '.tsv';
		if not found then
			exit;
		end if;
	  
	    EXECUTE format ('
			copy (
			  select * from rank_result
			  where description = ''%s'' 
			) to ''%s''  csv delimiter E''\t'' header
		', recmodel.description, filepath);
	end loop;
	close cumodel;
	
	open cumodel for
	  select 
	    distinct description 
	    from  rank_result_form
	    order by description;
	
	loop
		fetch cumodel into recmodel;
		
		filepath := paramDir || 'rank_result_form_' || recmodel.description || '.tsv';
		if not found then
			exit;
		end if;
	  
	    EXECUTE format ('
			copy (
			  select * from rank_result_form
			  where description = ''%s'' 
			) to ''%s''  csv delimiter E''\t'' header
		', recmodel.description, filepath);
	end loop;
	close cumodel;
	
  END
$$ LANGUAGE plpgsql;


select copyto_rank_result('F:\Dev\experiment\expr02\dbbackup\result_tables\');
