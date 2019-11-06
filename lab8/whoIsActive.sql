SELECT sqltext.[text]
	,req.[session_id]
	,req.[status]
	,req.[start_time]
	,req.[command]
	,req.[cpu_time]
	,req.[total_elapsed_time]
	,DB_NAME(req.[database_id]) AS DatabaseName
	,req.[blocking_session_id]
	,req.[wait_type]
	,req.[wait_time]
	,req.[open_transaction_count]
	,req.[estimated_completion_time]
	,req.[reads]
	,req.[writes]
FROM [sys].[dm_exec_requests] req
CROSS APPLY [sys].[dm_exec_sql_text]([sql_handle]) AS sqltext


