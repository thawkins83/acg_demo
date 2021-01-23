import os
import boto3
import json

running = "running"
terminated = "terminated"
stopped = "stopped"
name = "Name"


def lambda_handler(event, context):
    playbook = None
    sns_message = event['Records'][0]['Sns']['Message']
    message = json.loads(sns_message)
    instance_id = message['detail']['instance-id']
    state = message['detail']['state']

    if state == running or state == terminated or state == stopped:
        ec2_client = boto3.client('ec2')
        instance = ec2_client.describe_instances(
            InstanceIds=[
                instance_id
            ],
            Filters=[
                {
                    'Name': 'tag:ManagedBy',
                    'Values': [
                        'Ansible'
                    ]
                }
            ]
        )

        reservations = instance['Reservations']
        if len(reservations) != 0:
            for tag in reservations[0]['Instances'][0]['Tags']:
                if tag['Key'] == 'Playbook':
                    playbook = tag['Value']
            if playbook is not None:
                process_event(instance_id, state, playbook)


def process_event(instance_id, state, playbook):
    ssm_client = boto3.client('sms')
    instance_association_name = 'ansible-association-{}'.format(instance_id)
    status_infos = ssm_client.describe_instance_association_status(
        InstanceId=instance_id
    )
    association = status_infos['InstanceAssociationStatusInfos']
    association_exists = False
    if association is not None:
        for i in range(len(association)):
            if instance_association_name == association[i]['AssociationName']:
                association_exists = True

    if association_exists is False and running == state:
        print('Creating SSM State Manager Association: {}'.format(instance_id))
        create_association(ssm_client, playbook, instance_id, instance_association_name)
    else:
        association_id = get_association_id(ssm_client, instance_id, instance_association_name)
        if association_id is not None:
            if running == state:
                print('Updating SSM State Manager Association: {}'.format(association_id))
                update_association(ssm_client, association_id, instance_association_name, playbook)
            elif terminated == state:
                print('Deleting SSM State Manager Association: {}'.format(association_id))
                delete_association(ssm_client, association_id)
        else:
            print('Association does not exist: {}'.format(instance_association_name))


def get_association_id(ssm_client, instance_id, instance_association_name):
    response = ssm_client.describe_instance_associations_status(
        InstanceId=instance_id
    )
    association = response['InstanceAssociationStatusInfos']
    for i in range(len(association)):
        if instance_association_name == association[i]['AssociationName']:
            return association[i]['AssociationId']


def create_association(ssm_client, playbook, instance_id, instance_association_name):
    response = ssm_client.create_association(
        Name='AWS-ApplyAnsiblePlaybook',
        AssociationName=instance_association_name,
        Targets=[
            {
                'Key': 'InstanceIds',
                'Values': [
                    instance_id
                ]
            }
        ],
        Parameters=ssm_params(playbook)
    )
    association_id = response['AssociationDescription']['AssociationId']
    print('AssociationId: {}'.format(association_id))


def update_association(ssm_client, association_id, instance_association_name, playbook):
    response = ssm_client.update_association(
        AssociationId=association_id,
        AssociationName=instance_association_name,
        Parameters=ssm_params(playbook)
    )
    association_version = response['AssociationDescription']['AssociationVersion']
    print('AssociationId: {} updated to version: {}'.format(association_id, association_version))


def delete_association(ssm_client, association_id):
    response = ssm_client.delete_association(
        AssociationId=association_id
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('AssociationId: {} was successfully deleted.'.format(association_id))
    else:
        print('Error while deleting the Association: {}'.format(association_id))


def ssm_params(playbook):
    return {
        "Check": [
            "False"
        ],
        "InstallDependencies": [
            "True"
        ],
        "PlaybookFile": [
            playbook
        ],
        "Verbose": [
            "-v"
        ],
        "SourceInfo": [
            "{\n    \"path\":\"https://s3.amazonaws.com/" + os.environ['code_bucket'] + "/\"\n}"
        ],
        "SourceType": [
            "S3"
        ],
        "ExtraVariables": [
            "SSM=True"
        ]
    }

