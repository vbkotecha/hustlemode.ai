import json
import os
import psycopg2
import boto3
from datetime import datetime, timezone
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS Services
sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

# Database connection parameters from environment variables
DB_HOST = os.environ['DB_HOST']
DB_NAME = os.environ['DB_NAME']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']

def get_db_connection():
    """Create and return a database connection."""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except psycopg2.Error as e:
        logger.error(f"Database connection error: {e}")
        raise

def store_checkin(user_id: str, message: str, channel: str = 'business_chat'):
    """Store a check-in message in the database."""
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO checkins (user_id, message, channel, timestamp)
                VALUES (%s, %s, %s, %s)
                RETURNING id;
            """, (user_id, message, channel, datetime.now(timezone.utc)))
            checkin_id = cur.fetchone()[0]
            conn.commit()
            return checkin_id
    except psycopg2.Error as e:
        logger.error(f"Database error while storing check-in: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()

def generate_ai_response(message: str, context: dict = None) -> str:
    """Generate an AI response using Amazon Bedrock."""
    # TODO: Implement Bedrock integration
    # For now, return a simple encouraging message
    responses = [
        "Great job staying accountable! Keep up the good work!",
        "Thank you for checking in. Your commitment to discipline is inspiring!",
        "Every check-in is a step toward your goals. Well done!",
        "Your consistency is building a foundation for success!"
    ]
    from random import choice
    return choice(responses)

def send_notification(user_id: str, message: str, phone_number: str = None):
    """Send a notification via SNS."""
    try:
        # Prepare the message attributes for RCS
        message_attributes = {
            'AWS.SNS.SMS.SMSType': {
                'DataType': 'String',
                'StringValue': 'Promotional'  # or 'Transactional'
            }
        }
        
        # If phone number is provided, send directly to the number
        if phone_number:
            response = sns.publish(
                PhoneNumber=phone_number,
                Message=message,
                MessageAttributes=message_attributes
            )
        else:
            # Otherwise, publish to the topic
            response = sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=message,
                MessageAttributes=message_attributes
            )
        
        logger.info(f"Notification sent successfully: {response['MessageId']}")
        return response['MessageId']
    except Exception as e:
        logger.error(f"Error sending notification: {e}")
        raise

def process_daily_checkins():
    """Process daily check-ins and send reminders."""
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # Get users who haven't checked in today
            cur.execute("""
                SELECT DISTINCT user_id
                FROM checkins
                WHERE NOT EXISTS (
                    SELECT 1 FROM checkins c2
                    WHERE c2.user_id = checkins.user_id
                    AND DATE(c2.timestamp) = CURRENT_DATE
                );
            """)
            missing_checkins = cur.fetchall()
            
            # Send reminders to users who haven't checked in
            for user_id in missing_checkins:
                try:
                    send_notification(
                        user_id[0],
                        "Don't forget to check in today! Stay accountable to your goals."
                    )
                except Exception as e:
                    logger.error(f"Failed to send reminder to user {user_id[0]}: {e}")
            
            # Log the results
            logger.info(f"Found {len(missing_checkins)} users who haven't checked in today")
            return {
                'processed_count': len(missing_checkins),
                'timestamp': datetime.now(timezone.utc).isoformat()
            }
    except psycopg2.Error as e:
        logger.error(f"Database error while processing daily check-ins: {e}")
        raise
    finally:
        conn.close()

def handler(event, context):
    """Main Lambda handler function."""
    try:
        # Check if this is a scheduled event
        if event.get('source') == 'aws.events':
            logger.info("Processing scheduled daily check-ins")
            result = process_daily_checkins()
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Daily check-ins processed successfully',
                    'details': result
                })
            }
        
        # Process API Gateway event
        body = json.loads(event.get('body', '{}'))
        
        # Validate required fields
        required_fields = ['user_id', 'message']
        if not all(field in body for field in required_fields):
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Missing required fields',
                    'required_fields': required_fields
                })
            }
        
        # Store the check-in
        checkin_id = store_checkin(
            body['user_id'],
            body['message'],
            body.get('channel', 'business_chat')
        )
        
        # Generate AI response
        ai_response = generate_ai_response(
            body['message'],
            body.get('context', {})
        )
        
        # Send notification with AI response
        if body.get('phone_number'):
            send_notification(
                body['user_id'],
                ai_response,
                body['phone_number']
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'checkin_id': checkin_id,
                'message': 'Check-in recorded successfully',
                'ai_response': ai_response,
                'timestamp': datetime.now(timezone.utc).isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        } 