import boto3
import json
import logging
import os

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
functions = {}
SQS_QUEUE_URL = os.environ["OUTBOUNDQUEUE"]
sqs_client = boto3.client('sqs')
lambda_client = boto3.client('lambda')


def lambda_handler(event, context):
    global functions
    command = get_command_from_message(event["message"])
    response = invoke_function_if_found(command, event["message"])
    if not response:
        logging.warning("Not found, reloading")
        functions = load_functions_from_parameters()
        response = invoke_function_if_found(command, event["message"])
    
    if not response:
        return False
    else:
        send_response(response)
        return True


def invoke_function_if_found(command, message):
    if command in functions:
        # TODO: Call Lambda, return response
        logging.info(f"found {command}")
        logging.info(functions[command])
        response = lambda_client.invoke(
            FunctionName=functions[command],
            InvocationType='RequestResponse',  # Use 'Event' for async invocation
            Payload=json.dumps(message)
        )
        response_payload = json.loads(response['Payload'].read())
        logging.info(response_payload)
        return response_payload
    else:
        return False

def send_response(message_body):
    response = sqs_client.send_message(
        QueueUrl=SQS_QUEUE_URL,
        MessageBody=json.dumps(message_body)
        )
    logger.info(response)
    

def get_command_from_message(message):
    return message.split(" ")[0].replace("/","")

def load_functions_from_parameters():
    built_parameters = {}
    raw_parameters = get_parameters_by_pattern("/signalbot/function/")
    for item in raw_parameters:
        json_item = json.loads(item["Value"])
        built_parameters[json_item["invoke_string"]] = json_item["arn"]
    return built_parameters

def get_parameters_by_pattern(pattern, region='us-east-2'):
    # Initialize a session using boto3
    session = boto3.Session(region_name=region)
    ssm_client = session.client('ssm')

    # List to hold all matching parameters
    parameters = []

    # Paginate through results
    paginator = ssm_client.get_paginator('describe_parameters')
    page_iterator = paginator.paginate(
        ParameterFilters=[
            {
                'Key': 'Name',
                'Option': 'BeginsWith',
                'Values': [pattern]
            }
        ]
    )

    for page in page_iterator:
        for param in page['Parameters']:
            parameters.append(param['Name'])

    # Retrieve the parameter values
    parameter_details = ssm_client.get_parameters(
        Names=parameters,
        WithDecryption=True
    )

    return parameter_details['Parameters']