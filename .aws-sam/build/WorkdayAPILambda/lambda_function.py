from datetime import datetime

def lambda_handler(event, context):
    return {
        'statusCode': 200, 
        'body': f'Hello from Lambda part 1, This cicd works! Deployed at {datetime.now().isoformat()}'
    } 