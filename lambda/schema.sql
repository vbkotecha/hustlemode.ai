-- Create checkins table
CREATE TABLE IF NOT EXISTS checkins (
    id SERIAL PRIMARY KEY,
    chat_id VARCHAR(100) NOT NULL,
    sender VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_checkins_chat_id ON checkins(chat_id);
CREATE INDEX IF NOT EXISTS idx_checkins_timestamp ON checkins(timestamp); 