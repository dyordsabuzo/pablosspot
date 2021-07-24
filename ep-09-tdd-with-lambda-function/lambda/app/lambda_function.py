import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class AccessKey(object):
    def __init__(self, user, region, param_access=None, param_secret=None):
        self.user = user
        self.param_region = region
        self.param_access = f'/{user}/ACCESS_KEY_ID' if param_access == None else param_access
        self.param_secret = f'/{user}/ACCESS_SECRET_KEY' if param_secret == None else param_secret
    
    def create_access_key(self):
        iam = boto3.client('iam')

        accesskeys = iam.list_access_keys(UserName=self.user)['AccessKeyMetadata']

        if len(accesskeys) > 0:
            keys = [a['AccessKeyId'] for a in sorted(accesskeys, key=lambda x: x['CreateDate'])]
            if len(keys) > 1:
                response = iam.delete_access_key(
                    UserName=self.user,
                    AccessKeyId=keys[0]
                )

        logger.info('Creating new accesskey')
        response = iam.create_access_key(UserName=self.user)['AccessKey']
        access_key = response['AccessKeyId']
        secret_key = response['SecretAccessKey']
        logger.info('New Access key created successfully')

        ssm = boto3.client('ssm', region_name=self.param_region)
        response = ssm.put_parameter(
            Name=self.param_access,
            Value=access_key,
            Type='String',
            Overwrite=True
        )
        response = ssm.put_parameter(
            Name=self.param_secret,
            Value=secret_key,
            Type='SecureString',
            Overwrite=True
        )
        logger.info('Parameter store updated successfully')

def handler(event, context):
    try:
        user = event['user']
        region = event['region']
        param_access = event['param_access'] if 'param_access' in event else None
        param_secret = event['param_secret'] if 'param_secret' in event else None

        a = AccessKey(user, region, param_access, param_secret)
        a.create_access_key()
    except Exception as e:
        raise e