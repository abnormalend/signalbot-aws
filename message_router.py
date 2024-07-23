import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# This empty dict will serve as a global list of valid functions.
functions = {}

# Set up the Queue for sending responses
SQS_QUEUE_URL = os.environ["OUTBOUNDQUEUE"]
sqs_client = boto3.client('sqs')

# Set up the lambda client so we can call the other functions
lambda_client = boto3.client('lambda')


def lambda_handler(event, context):
    global functions                #We want to accesss the functions dict
    command = get_command_from_message(event["message"])# Extract the command
    
    # We get two tries at finding the function, this also triggers the refresh
    response = invoke_function_if_found(command, event["message"])
    if not response:
        logging.warning(f"{command} not found, reloading")
        functions = load_functions_from_parameters() #Refresh
        response = invoke_function_if_found(command, event["message"])
    
    if not response:
        logging.warning("Sending failure message")
        send_response("TODO: Valid failure message here")
    else:
        send_response(response)
    return True


def invoke_function_if_found(command, message):
    if command in functions:
        logging.debug(f"found {command}")
        response = lambda_client.invoke(
            FunctionName=functions[command],
            InvocationType='RequestResponse',
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
    functions_dict = {}
    raw_parameters = get_parameters_by_pattern("/signalbot/function/")
    for item in raw_parameters:
        json_item = json.loads(item["Value"])
        functions_dict[json_item["invoke_string"]] = json_item["arn"]
    return functions_dict

def get_parameters_by_pattern(pattern):
    ssm_client = boto3.client('ssm')

    parameters = [] # List to hold all matching parameters

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