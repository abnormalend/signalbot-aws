import boto3
import os
from pyjokes import get_joke

ParameterInjector()

def lambda_handler(event, context):
    print(get_joke())


def ParameterInjector():
    client = boto3.client('sts')
    response = client.get_caller_identity()
    print(response)