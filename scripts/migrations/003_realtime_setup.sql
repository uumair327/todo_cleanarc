-- Migration 003: Real-time Setup
-- Enables real-time subscriptions for tasks table

-- Enable real-time for tasks table
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;

-- Create a function to notify on task changes (optional, for additional real-time features)
CREATE OR REPLACE FUNCTION notify_task_change()
RETURNS TRIGGER AS $$
DECLARE
    payload JSON;
BEGIN
    IF TG_OP = 'DELETE' THEN
        payload = json_build_object(
            'operation', TG_OP,
            'record', row_to_json(OLD),
            'user_id', OLD.user_id
        );
    ELSE
        payload = json_build_object(
            'operation', TG_OP,
            'record', row_to_json(NEW),
            'user_id', NEW.user_id
        );
    END IF;
    
    PERFORM pg_notify('task_changes', payload::text);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists (for idempotency)
DROP TRIGGER IF EXISTS task_change_trigger ON tasks;

-- Create trigger for task changes
CREATE TRIGGER task_change_trigger
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION notify_task_change();
