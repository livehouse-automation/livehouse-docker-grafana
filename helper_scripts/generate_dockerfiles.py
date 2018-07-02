#!/usr/bin/python3

import os

arch_images = {'amd64':   {'image': 'amd64/ubuntu:bionic',   'target': 'amd64'},
               'arm32v7': {'image': 'arm32v7/ubuntu:bionic', 'target': 'armhf'},
              }

for arch in arch_images.keys():
	baseimage = arch_images[arch]['image']
	target = arch_images[arch]['target']
	outputfile = os.path.join(os.getcwd(),arch,"Dockerfile")

	print("Making Dockerfile '%s' for %s using base image of %s for a target of %s" % 
		(outputfile, arch, baseimage, target))

	with open('Dockerfile.in', 'r') as dockerfile_in:
		read_data = dockerfile_in.read()
		read_data = read_data.replace("%BASEIMAGE%", baseimage)
		read_data = read_data.replace("%TARGET%", target)
		with open(outputfile, 'w') as dockerfile_out:
			dockerfile_out.write(read_data)

print('Done!')


