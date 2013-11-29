#!/bin/env python
#coding=utf-8

import sys
import os
import pexpect

def main():
	remote = sys.argv[1]
	passwd = sys.argv[2]
	ssh_cmd = remote

	ssh = pexpect.spawn ('/bin/bash', ['-c', ssh_cmd], timeout=10000)
	pwd_count = 0
	while 1:
		try:
			index = ssh.expect(['\(yes/no\)\?', 'assword:'])
			if index == 0:
				ssh.sendline("yes")
			elif index == 1:
				if pwd_count > 0:
					print "Password is wrong"
					return
				else:
					ssh.sendline(passwd)
				pwd_count = pwd_count + 1
		except pexpect.EOF:
			break
		except pexpect.TIMEOUT:
			break
	pass

if __name__ == '__main__':
	main()

