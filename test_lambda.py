#!/usr/bin/env python3
"""
Simple test script to verify Lambda function deployment
"""
import boto3
import json

def test_lambda_function():
    """Test the deployed Lambda function"""
    lambda_client = boto3.client('lambda')
    
    try:
        # Invoke the Lambda function
        response = lambda_client.invoke(
            FunctionName='MyEnterpriseLambda',
            InvocationType='RequestResponse'
        )
        
        # Parse the response
        payload = json.loads(response['Payload'].read())
        print(f"Lambda Response: {payload}")
        
        # Check if the response contains the expected message
        if 'Hello from Lambda part 1!' in payload.get('body', ''):
            print("✅ SUCCESS: Lambda function is updated with new code!")
        else:
            print("❌ FAILED: Lambda function still has old code")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")

if __name__ == "__main__":
    print("Testing Lambda function deployment...")
    test_lambda_function() 