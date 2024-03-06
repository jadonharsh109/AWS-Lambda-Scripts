import boto3

# Function to stop EC2 instances in a specific region
def stop_instances_in_region(region):
    ec2 = boto3.client('ec2', region_name=region)
    # Retrieve all EC2 instances in the running state
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )
    
    # Collect all instance ids that are in the running state
    instance_ids = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
    
    # Stop the instances if there are any running
    if instance_ids:
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f'Stopped instances in region {region}: {instance_ids}')
    else:
        print(f'No instances to stop in region {region}')

def lambda_handler(event, context):
    # Retrieve all regions for EC2 service
    ec2 = boto3.client('ec2')
    regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]
    
    # Stop EC2 instances in each region
    for region in regions:
        stop_instances_in_region(region)

    return {
        'statusCode': 200,
        'body': 'EC2 stop process initiated across all regions'
    }