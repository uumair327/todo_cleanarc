-- Migration: Add attachments support
-- Description: Creates attachments table and storage bucket for task file attachments

-- Create attachments table
CREATE TABLE IF NOT EXISTS attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_url TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_attachments_task_id ON attachments(task_id);
CREATE INDEX IF NOT EXISTS idx_attachments_uploaded_at ON attachments(uploaded_at DESC);

-- Add RLS policies for attachments
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;

-- Users can view attachments for their own tasks
CREATE POLICY "Users can view their own task attachments"
    ON attachments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM tasks
            WHERE tasks.id = attachments.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- Users can insert attachments for their own tasks
CREATE POLICY "Users can insert attachments for their own tasks"
    ON attachments FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM tasks
            WHERE tasks.id = attachments.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- Users can delete their own task attachments
CREATE POLICY "Users can delete their own task attachments"
    ON attachments FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM tasks
            WHERE tasks.id = attachments.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- Create storage bucket for task attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('task-attachments', 'task-attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Add storage policies
CREATE POLICY "Users can upload attachments for their tasks"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'task-attachments'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view their own attachments"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'task-attachments'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete their own attachments"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'task-attachments'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Add attachment_ids column to tasks table (optional, for denormalization)
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS attachment_ids TEXT[] DEFAULT '{}';

-- Create function to update attachment_ids when attachments are added/removed
CREATE OR REPLACE FUNCTION update_task_attachment_ids()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE tasks
        SET attachment_ids = array_append(attachment_ids, NEW.id::text)
        WHERE id = NEW.task_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE tasks
        SET attachment_ids = array_remove(attachment_ids, OLD.id::text)
        WHERE id = OLD.task_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update attachment_ids
DROP TRIGGER IF EXISTS trigger_update_task_attachment_ids ON attachments;
CREATE TRIGGER trigger_update_task_attachment_ids
    AFTER INSERT OR DELETE ON attachments
    FOR EACH ROW
    EXECUTE FUNCTION update_task_attachment_ids();

-- Add updated_at trigger for attachments
CREATE OR REPLACE FUNCTION update_attachments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_attachments_updated_at ON attachments;
CREATE TRIGGER trigger_attachments_updated_at
    BEFORE UPDATE ON attachments
    FOR EACH ROW
    EXECUTE FUNCTION update_attachments_updated_at();
