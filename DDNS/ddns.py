import requests, json
import os
import sys

API_KEY = ''
EMAIL = ''
ZONE_NAME = ''
RECORD_NAME = ''


def get_addr():
	url = 'http://ip.sb'
	headers = {'User-Agent': 'curl/7.79.1'}
	ret = requests.get(url, headers=headers)
	return ret.text


def update_record(new_ip_address):
	# 获取 zone_id
	zone_url = f'https://api.cloudflare.com/client/v4/zones?name={ZONE_NAME}'
	zone_headers = {'X-Auth-Email': EMAIL, 'X-Auth-Key': API_KEY, 'Content-Type': 'application/json'}
	zone_response = requests.get(zone_url, headers=zone_headers)
	zone_id = zone_response.json()['result'][0]['id']
	print(zone_id)

	# 获取 record_id
	record_url = f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records'
	record_response = requests.get(record_url, headers=zone_headers)
	print(record_response.json())
	response_data = json.loads(record_response.text)

	# Check if response is OK
	if record_response.status_code == 200:
		for record in response_data['result']:
			if record['name'] == f'{RECORD_NAME}.{ZONE_NAME}':
				record_id = record['id']
				print('Record ID:', record_id)
				break
			else:
				print('DNS record not found.')
	else:
		print('Failed to get DNS records. Error message:', response_data['errors'][0]['message'])

	# 更新记录
	record_data = {'type': 'A', 'name': RECORD_NAME, 'content': new_ip_address}
	record_url = f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}'
	record_response = requests.put(record_url, headers=zone_headers, json=record_data)

	print(record_response.text)


def main():
	new = get_addr()
	print(new)
	pwd = os.path.dirname(os.path.realpath(__file__))
	last_ip_file = os.path.join(pwd, 'last.ip')
	if not os.path.exists(last_ip_file):
		# 文件不存在,先创建并写入当前地址
		print(f'{last_ip_file} 不存在,创建并写入ip地址')
		update_record(new)
		with open('last.ip', 'w') as f:
			f.write(new)
		return

# 直接更新域名解析记录
# update_record()
	print(f'{last_ip_file} 已存在,读取上一次的ip地址')
	with open(last_ip_file, 'r') as f:
		old = f.readline()
		print(old)
	if old != new:
		print('监测到地址变化,更新DNS记录..')
		update_record(new)
		with open('last.ip', 'w') as f:
			f.write(new)

if __name__ == '__main__':
	main()

