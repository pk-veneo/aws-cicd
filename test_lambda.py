#!/usr/bin/env python3
"""
Simple test script to verify Lambda function deployments
"""
import boto3
import json

def test_lambda_function(function_name, expected_message):
    """Test a specific Lambda function"""
    lambda_client = boto3.client('lambda')
    
    try:
        # Invoke the Lambda function
        response = lambda_client.invoke(
            FunctionName=function_name,
            InvocationType='RequestResponse'
        )
        
        # Parse the response
        payload = json.loads(response['Payload'].read())
        print(f"\n📋 {function_name} Response:")
        print(f"   Status Code: {payload.get('statusCode')}")
        
        if payload.get('statusCode') == 200:
            body = json.loads(payload.get('body', '{}'))
            print(f"   Body: {body}")
            
            if expected_message in str(body):
                print(f"   ✅ SUCCESS: {function_name} is working correctly!")
                return True
            else:
                print(f"   ❌ FAILED: {function_name} response doesn't match expected")
                return False
        else:
            print(f"   ❌ FAILED: {function_name} returned error status")
            return False
            
    except Exception as e:
        print(f"   ❌ ERROR testing {function_name}: {e}")
        return False

def test_all_functions():
    """Test all deployed Lambda functions"""
    print("🧪 Testing Lambda function deployments...")
    
    # Test the original function
    original_success = test_lambda_function(
        'MyEnterpriseLambda', 
        'Hello from Lambda part 1'
    )
    
    # Test the Workday API function
    workday_success = test_lambda_function(
        'WorkdayAPILambda', 
        'Workday API integration successful'
    )
    
    # Summary
    print(f"\n📊 Test Summary:")
    print(f"   MyEnterpriseLambda: {'✅ PASS' if original_success else '❌ FAIL'}")
    print(f"   WorkdayAPILambda: {'✅ PASS' if workday_success else '❌ FAIL'}")
    
    if original_success and workday_success:
        print("\n🎉 All Lambda functions are working correctly!")
    else:
        print("\n⚠️  Some Lambda functions need attention.")

if __name__ == "__main__":
    test_all_functions() 