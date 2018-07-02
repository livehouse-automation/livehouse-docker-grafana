#!/usr/bin/python3

import os

arch_images = {'amd64':   {'image':  'amd64/ubuntu:bionic',   
                           'target': 'amd64', 
                           'goarch': 'amd64',
                           'gourl':  'https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz',},
               'arm32v7': {'image':  'arm32v7/ubuntu:bionic', 
                           'target': 'armhf', 
                           'goarch': 'arm'
                           'gourl':  'https://dl.google.com/go/go1.10.3.linux-armv6l.tar.gz'},
              }

for arch in arch_images.keys():
	baseimage = arch_images[arch]['image']
	target = arch_images[arch]['target']
	outputfile = os.path.join(os.getcwd(),arch,"Dockerfile")
	gourl = arch_images[arch]['gourl']

	print("Making Dockerfile '%s' for %s using base image of %s for a target of %s" % 
		(outputfile, arch, baseimage, target))

	with open('Dockerfile.in', 'r') as dockerfile_in:
		read_data = dockerfile_in.read()
		read_data = read_data.replace("%BASEIMAGE%", baseimage)
		read_data = read_data.replace("%TARGET%", target)
		read_data = read_data.replace("%GOURL%", gourl)
		with open(outputfile, 'w') as dockerfile_out:
			dockerfile_out.write(read_data)

print('Done!')


