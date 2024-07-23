import json
from pyjokes import get_joke


def lambda_handler(event, context):
    return get_joke()
