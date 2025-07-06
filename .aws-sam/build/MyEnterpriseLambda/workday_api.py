import json
import boto3
import requests
from datetime import datetime

def lambda_handler(event, context):
    """
    Lambda function for Workday API integration
    """
    try:
        # Example Workday API call (replace with your actual Workday API details)
        workday_response = {
            "status": "success",
            "timestamp": datetime.now().isoformat(),
            "message": "Workday API integration successful",
            "data": {
                "employees": [],
                "departments": [],
                "last_sync": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(workday_response)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e),
                'message': 'Workday API integration failed'
            })
        } 