import boto3
import os
from pyjokes import get_joke


def lambda_handler(event, context):
    print(get_joke())
