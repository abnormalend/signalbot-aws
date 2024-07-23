import boto3
import json
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
functions = {}

def lambda_handler(event, context):
    global functions
    command = get_command_from_message(event["message"])
    response = invoke_function_if_found(command)
    if not response:
        logging.warning("Not found, reloading")
        functions = load_functions_from_parameters()
        response = invoke_function_if_found(command)
    
    if not response:
        return False
    else:
        return response
        
    
    # if command in functions:
    #     logging.info(f"found {command}")
    # else:
    #     logging.warning(f"Function {command} not found, reloading function list from parameter store")
    #     functions = load_functions_from_parameters()

def invoke_function_if_found(command):
    if command in functions:
        # TODO: Call Lambda, return response
        logging.info(f"found {command}")
        return True
    else:
        return False
        

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