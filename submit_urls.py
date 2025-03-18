import requests
import json
import time

# Your IndexNow configuration
key = "fddf21c6074f44b69cfecedb9a7ad62d"
host = "hustlemode.ai"
key_location = f"https://{host}/{key}.txt"

# List of URLs to submit
urls = [
    f"https://{host}",
    f"https://{host}/about.html",
    f"https://{host}/support.html"
]

# IndexNow endpoints
endpoints = [
    "https://api.indexnow.org/IndexNow",  # Automatically distributes to participating search engines
    "https://www.bing.com/IndexNow",      # Bing direct endpoint
    "https://yandex.com/indexnow",        # Yandex direct endpoint
]

# Prepare the request payload
payload = {
    "host": host,
    "key": key,
    "keyLocation": key_location,
    "urlList": urls
}

# Submit to each endpoint
for endpoint in endpoints:
    print(f"\nSubmitting to {endpoint}...")
    try:
        response = requests.post(
            endpoint,
            headers={"Content-Type": "application/json; charset=utf-8"},
            data=json.dumps(payload),
            timeout=10
        )
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error submitting to {endpoint}: {str(e)}")
    
    # Wait a bit between submissions to avoid rate limiting
    time.sleep(2)

# Submit to Google using their Indexing API (requires separate setup)
print("\nNote: To submit to Google, use Google Search Console's URL Inspection Tool"
      "\nor set up the Indexing API for automated submissions.") 