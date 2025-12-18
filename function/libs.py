import logging
from cloudevents.http import CloudEvent

import hashlib
import string

import os
import yaml
import json

ALPHABET = string.ascii_letters + string.digits  # base62

def base62_encode(num: int) -> str:
    if num == 0:
        return ALPHABET[0]
    out = []
    base = len(ALPHABET)
    while num:
        num, rem = divmod(num, base)
        out.append(ALPHABET[rem])
    return ''.join(reversed(out))

def short_hash(data: bytes, length=10) -> str:
    h = hashlib.sha256(data).digest()
    n = int.from_bytes(h, "big")
    return base62_encode(n)[:length]


def cloudevent_to_dict(event: CloudEvent) -> dict:
    return dict({
        "specversion": event["specversion"],
        "id": event["id"],
        "source": event["source"],
        "type": event["type"],
        #"subject": event.get("subject"),
        #"time": event.get("time"),
        #"datacontenttype": event.get("datacontenttype"),
        #"data": event.data,
    })

async def handleYamlToJSON(scope, receive, send):
    """ Library handler that fans out to converting a Yaml file to JSON
    and responds successfully by giving the user the appropriate method
    to receive the converted file"""

    request = scope["event"]

    logging.info(f"handleYamlToJson:request_id={request.get('id', 'unknown')}: user requested to convert a body to")

    payload = cloudevent_to_dict(request)

    obj_id = short_hash(json.dumps(payload).encode(), 10)

    response = CloudEvent({
        "type": "dev.knative.converter.YamlToJSON",
        "source": "https://delivery.converter.knative.dev/python-receive-response",
        "id": f"{request.get('id','unknown')}-ask-{obj_id}"
    })

    response.data = {
        "task": "send event as type $type and hash $hash from $id-ask-$hash from headers to obtain the results"
    }
    await send(response)

    # Step 1: Convert YAML string to a Python dictionary
    # Use yaml.safe_load() for security
    python_object = yaml.safe_load(request.data)

    # Step 2: Convert Python dictionary to a JSON formatted string
    # Use indent=4 for human-readable output
    json_string = json.dumps(python_object, indent=4)

    tmp_path = f"./data/{obj_id}.json.tmp"
    final_path = f"./data/{obj_id}.json"

    with open(tmp_path, "w") as f:
        json.dump(json_string, f)
        f.flush()
        os.fsync(f.fileno())

    os.rename(tmp_path, final_path)
