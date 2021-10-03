import unittest
import lambda_function
import boto3
import botocore

from moto import mock_iam, mock_ssm
from lambda_function import AccessKey

class AccessKeyTest(unittest.TestCase):
    def test_init(self):
        username = 'abc'
        a = AccessKey(username, 'us-east-1')
        self.assertEqual(a.user, username)
        self.assertEqual(a.param_region, 'us-east-1')
        self.assertEqual(a.param_access, f'/{username}/ACCESS_KEY_ID')
        self.assertEqual(a.param_secret, f'/{username}/ACCESS_SECRET_KEY')
    
    def test_custom_params(self):
        a = AccessKey('abc', 'us-east-1', '/custom/access', '/custom/secret')
        self.assertEqual(a.param_access, '/custom/access')
        self.assertEqual(a.param_secret, '/custom/secret')

    @mock_iam
    @mock_ssm
    def test_setting_parameters(self):
        user = 'abc'
        region = 'us-east-1'

        iam = boto3.client('iam')
        iam.create_user(UserName=user)

        a = AccessKey(user, region, '/custom/access', '/custom/secret')
        a.create_access_key()

        ssm = boto3.client('ssm', region_name=region)
        key = ssm.get_parameter(Name='/custom/access')['Parameter']['Value']
        self.assertIsNotNone(key)
        secret = ssm.get_parameter(Name='/custom/secret')['Parameter']['Value']
        self.assertIsNotNone(secret)

    @mock_iam
    @mock_ssm
    def test_param_not_blank(self):
        user = 'abc'
        region = 'us-east-1'
        
        iam = boto3.client('iam')
        iam.create_user(UserName=user)

        a = AccessKey(user, region, '/custom/access', '/custom/secret')
        a.create_access_key()

        ssm = boto3.client('ssm', region_name=region)
        key = ssm.get_parameter(Name='/custom/access')['Parameter']['Value']
        self.assertNotEqual(key, '')
        secret = ssm.get_parameter(Name='/custom/secret')['Parameter']['Value']
        self.assertNotEqual(secret, '')
    
    @mock_iam
    @mock_ssm
    def test_user_not_existing(self):
        user = 'abc'
        a = AccessKey(user, 'us-east-1')
        self.assertRaises(botocore.exceptions.ClientError, a.create_access_key)
    
    @mock_iam
    @mock_ssm
    def test_multiple_keys(self):
        user = 'abc'
        region = 'us-east-1'

        iam = boto3.client('iam')
        iam.create_user(UserName=user)

        a = AccessKey(user, region)
        a.create_access_key()

        accesskeys = iam.list_access_keys(UserName=user)['AccessKeyMetadata']
        first_access_key = accesskeys[0]
        self.assertEqual(1, len(accesskeys))

        a.create_access_key()
        accesskeys = iam.list_access_keys(UserName=user)['AccessKeyMetadata']
        self.assertEqual(2, len(accesskeys))

        a.create_access_key()
        accesskeys = iam.list_access_keys(UserName=user)['AccessKeyMetadata']
        self.assertEqual(2, len(accesskeys))
        self.assertTrue(first_access_key not in accesskeys)

    @mock_iam
    @mock_ssm
    def test_handler(self):
        user = 'abc'
        region = 'us-east-1'

        iam = boto3.client('iam')
        iam.create_user(UserName=user)

        event = {
            'user': user,
            'region': region
        }

        lambda_function.handler(event, None)
        ssm = boto3.client('ssm', region_name=region)
        key = ssm.get_parameter(Name=f'/{user}/ACCESS_KEY_ID')['Parameter']['Value']
        self.assertNotEqual(key, '')
    
    def test_handler_exception(self):
        event = {
            'user' : 'abc'
        }
        self.assertRaises(Exception, lambda_function.handler, event, None)

if __name__ == '__main__':
    unittest.main()