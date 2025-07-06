#!/usr/bin/env python3
"""
Local testing script for serverless Lambda functions
"""

import json
import subprocess
import sys
import os

def run_sam_local_api():
    """Start SAM local API for testing"""
    print("🚀 Starting SAM Local API...")
    try:
        subprocess.run([
            "sam", "local", "start-api", 
            "--template", "template.yaml",
            "--port", "3000",
            "--host", "0.0.0.0"
        ], check=True)
    except KeyboardInterrupt:
        print("\n⏹️  Stopping SAM Local API...")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error starting SAM Local API: {e}")
        sys.exit(1)

def test_lambda_function(function_name, event_file=None):
    """Test a specific Lambda function locally"""
    print(f"🧪 Testing {function_name}...")
    
    # Default event for testing
    default_event = {
        "httpMethod": "GET",
        "path": "/api/enterprise",
        "headers": {
            "Content-Type": "application/json"
        },
        "queryStringParameters": {},
        "body": None
    }
    
    event_data = default_event
    if event_file and os.path.exists(event_file):
        with open(event_file, 'r') as f:
            event_data = json.load(f)
    
    # Create temporary event file
    temp_event_file = f"temp_event_{function_name}.json"
    with open(temp_event_file, 'w') as f:
        json.dump(event_data, f, indent=2)
    
    try:
        result = subprocess.run([
            "sam", "local", "invoke", function_name,
            "--template", "template.yaml",
            "--event", temp_event_file
        ], capture_output=True, text=True, check=True)
        
        print(f"✅ {function_name} test completed")
        print(f"Output: {result.stdout}")
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error testing {function_name}: {e}")
        print(f"Error output: {e.stderr}")
    finally:
        # Clean up temp file
        if os.path.exists(temp_event_file):
            os.remove(temp_event_file)

def build_sam():
    """Build SAM application"""
    print("🔨 Building SAM application...")
    try:
        subprocess.run([
            "sam", "build", 
            "--template", "template.yaml"
        ], check=True)
        print("✅ SAM build completed")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error building SAM: {e}")
        sys.exit(1)

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python local-test.py build          # Build SAM application")
        print("  python local-test.py api            # Start local API")
        print("  python local-test.py test <function> # Test specific function")
        return
    
    command = sys.argv[1]
    
    if command == "build":
        build_sam()
    elif command == "api":
        run_sam_local_api()
    elif command == "test":
        if len(sys.argv) < 3:
            print("❌ Please specify function name: python local-test.py test <function>")
            return
        function_name = sys.argv[2]
        event_file = sys.argv[3] if len(sys.argv) > 3 else None
        test_lambda_function(function_name, event_file)
    else:
        print(f"❌ Unknown command: {command}")

if __name__ == "__main__":
    main() 