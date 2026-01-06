import json
import urllib.request

URL = "https://open.er-api.com/v6/latest/USD"

def lambda_handler(event, context):
    with urllib.request.urlopen(URL, timeout=10) as r:
        data = json.loads(r.read().decode("utf-8"))

    krw = data["rates"]["KRW"]

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "base": "USD",
            "target": "KRW",
            "rate": float(krw),
            "version": "v1"
        })
    }



    except Exception as e:
        return {
            "statusCode": 502,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
