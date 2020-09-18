from flask import Flask
from google.cloud import logging
from google.cloud.logging.resource import Resource
import random
import os

app = Flask(__name__)

# resource_type: "cloud_run_revision" (from Dockerfile),
# GCP Resource that we use.
# If not set this log can be found in
# the Cloud Logging console under 'Custom Logs'.
# or using the less efficient global restriction
resource_type = os.environ['RESOURCE_TYPE']

# service_name: "logging-basis" (from Dockerfile),
# service_name is a Cloud Run property
service_name = os.environ['SERVICE']

# region: "us-east1" (from Dockerfile)
region = os.environ['REGION']

# Log Name
log_name = 'choose_side'

'''Stackdriver Logging config (This could be a Class)'''
logging_client = logging.Client()
logger = logging_client.logger(log_name)
resource = Resource(
    type=resource_type,
    labels={
        "service_name": service_name,
        "location": region
    })


@app.route("/", methods=['GET'])
def choose_side():
    """
    This method chooses a random side and return a simple message.
    :return: String message to the client
    """

    # Getting the side
    side_random = random.randrange(2)
    side = 'Dark side' if side_random == 0 else 'Light side'
    struct = {
        'sideRandom': side_random,
        'side': side,
    }

    # Sending log to Stackdriver Logging
    logger.log_struct(struct, resource=resource, severity='INFO')

    # Response
    return "You're the {} [{}]".format(side, side_random)
