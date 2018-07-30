#!/usr/bin/python3

import os
import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Create Dockerfiles for each supported architecture (amd64 + arm32v7), and create build scripts')

    parser.add_argument('-t', '--tag',
        type=str,
        nargs=1,
        help='docker image tag',
        default='latest'
        )

    args = parser.parse_args()

    arch_images = {'amd64':   {'image':  'amd64/ubuntu:bionic',   
                               'target': 'amd64', 
                               'goarch': 'amd64',
                               'gourl':  'https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz',},
                   'arm32v7': {'image':  'arm32v7/ubuntu:bionic', 
                               'target': 'armhf', 
                               'goarch': 'arm',
                               'gourl':  'https://dl.google.com/go/go1.10.3.linux-armv6l.tar.gz'},
                  }

    # make dockerfiles, build.sh files and push.sh files for each architecture    
    for arch in arch_images.keys():

        baseimage = arch_images[arch]['image']
        target = arch_images[arch]['target']

        # make output dir
        output_dir = os.path.join(os.getcwd(),arch)
        if not os.path.isdir(output_dir):
            os.mkdir(output_dir)

        output_dockerfile = os.path.join(output_dir,"Dockerfile")
        output_buildscript = os.path.join(output_dir,"build.sh")
        output_pushscript = os.path.join(output_dir,"push.sh")
        gourl = arch_images[arch]['gourl']

        print("Making Dockerfile '%s' for %s using base image of %s for a target of %s" % 
            (output_dockerfile, arch, baseimage, target))

        with open('Dockerfile.in', 'r') as dockerfile_in:
            read_data = dockerfile_in.read()
            read_data = read_data.replace("%BASEIMAGE%", baseimage)
            read_data = read_data.replace("%TARGET%", target)
            read_data = read_data.replace("%GOURL%", gourl)
            with open(output_dockerfile, 'w') as dockerfile_out:
                dockerfile_out.write(read_data)

        print("Making build script '%s' for %s" % 
            (output_buildscript, arch))
        with open(output_buildscript, 'w') as buildscript_out:
            buildscript = """#!/bin/bash

ARCH="%s"
IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="%s"

echo "BUILDING $ARCH"
docker build -t $IMAGENAME:$TAG-$ARCH .
""" % (arch, args.tag[0])
            buildscript_out.write(buildscript)

        with open(output_pushscript, 'w') as pushscript_out:
            pushscript = """#!/bin/bash

ARCH="%s"
IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="%s"

echo "PUSHING TO DOCKER HUB"
docker push $IMAGENAME:$TAG-$ARCH
""" % (arch, args.tag[0])
            pushscript_out.write(buildscript)

    # create manifest file
    output_manifest = os.path.join(os.getcwd(), "create_manifest.sh")
    print("Making manifest script '%s'" % (output_manifest))
    with open(output_manifest, 'w') as manifest_out:
        manifest_out.write("""#!/bin/bash

echo "CREATE MULTI-ARCH DOCKER MANIFEST"

IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="%s"

docker manifest create $IMAGENAME:$TAG $IMAGENAME:$TAG-arm32v7 $IMAGENAME:$TAG-amd64
docker manifest annotate $IMAGENAME:$TAG $IMAGENAME:$TAG-amd64 --os linux --arch amd64
docker manifest annotate $IMAGENAME:$TAG $IMAGENAME:$TAG-arm32v7 --os linux --arch arm --variant v7
docker manifest push $IMAGENAME:$TAG
""" % (args.tag[0]))

    print('Done!')


