# ecs_failover_lambda.py
import boto3
import os

def lambda_handler(event, context):
    ecs = boto3.client('ecs', region_name='eu-central-1')
    rds = boto3.client('rds', region_name='eu-central-1')
    
    try:
        # Scale up ECS service in DR
        ecs.update_service(
            cluster=os.environ['DR_ECS_CLUSTER'],
            service=os.environ['DR_ECS_SERVICE'],
            desiredCount=int(os.environ.get('DESIRED_COUNT', 2))
        )
        
        # Promote RDS read replica
        rds.promote_read_replica(
            DBInstanceIdentifier=os.environ['DR_RDS_ID']
        )
        
        return {
            'statusCode': 200,
            'body': 'Failover completed successfully!'
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Failover failed: {str(e)}'
        }