# XMLTV DOCKER

A docker implementation of [xmltv](https://github.com/XMLTV/xmltv) I created to run on my Synology DS918+ (but it will probably run on any docker host). I use it to update the tv guide on my Plex server.

Follow this guide to create a xmltv docker image on your docker host. The image is used to create and RUN a temporary docker container. When the container run's it will update the xmltv output file and the container will then be trashed. Schedule the docker RUN command on your host daily to update your xmltv.xml file.

## Updates

2024-02-23:
Forked from kibuan/xmltv_docker. Updated grab.sh script. Added ability to create configuration file. updated readme.


2024-02-10:
Updated tv_grab_dk_meetv. Fixes problem where the EPG guide in Plex showed the wrong arrings some channels.

2021-08-03:
Added support for meetv.dk grabber (tv_grab_dk_meetv) created by Klaus Madsen: https://sourceforge.net/p/xmltvdk/mailman/message/37168487/

## Getting Started

These instructions will guide you to build the xmltv docker image and get the xmltv container up and running.

### Prerequisites

```
Clone the files in this Github repository to a local folder on your docker host
(in this guide we use: /volume1/docker/xmltv/ on the host)
```

### Manually build a docker image file using the Dockerfile in this repository

Note: there is prebuild image available on Docker Hub (racle90/xmltv) if you don't want to build the image yourself.

# Clone repo

```
git clone https://github.com/racle90/xmltv_docker.git
cd xmltv_docker
``


```
# Build image
```
docker image build -t racle90/xmltv build/
```


# Usage

## create data folder
```
mkdir -p data/{output,config}
```

## configure the xmltv grabber for first time if you don't have a config file
```
docker container run --rm -ti \
--user $UID:$GID \
-v "./data/config/:/config" \
-v "./data/output/:/output" \
-e 'XMLTV_GRABBER=tv_grab_fi' \
racle90/xmltv configure
```


## optional: keep only wanted sources
```
docker container run --rm -ti \
--user $UID:$GID \
-v "./data/config/:/config" \
-v "./data/output/:/output" \
-e 'XMLTV_GRABBER=tv_grab_fi' \
-e 'XMLTV_DAYS=14' \
racle90/xmltv keep "peruskanavat.telkku.com"
```

## run the xmltv grabber
```
docker container run --rm -ti \
--user $UID:$GID \
-v "./data/config/:/config" \
-v "./data/output/:/output" \
-e 'XMLTV_GRABBER=tv_grab_fi' \
-e 'XMLTV_DAYS=14' \
racle90/xmltv
```




### Docker container Mounts and Environment variables

**Mounts (MANDATORY)**

| Mount | Host folder  | Example
|--|--|--|
|/root/.xmltv | 'Container work-dir' - folder to save your xmltv configuration and cache files on your docker-host | ```-v '/volume1/docker/xmltv/container:/root/.xmltv'```
|/opt/xml | xmltv .xml file output dir on your docker-host | ```-v '/volume1/docker/xmltv/container:/opt/xml'```

**Environment variables (OPTIONAL)**
|Environment variable | Description | Example
|--|--|--|
|OUTPUT_XML_FILENAME | The file name of the xmltv output .xml file (default=-grabber-.xml) | ```-e 'xmltv.xml'```
|XMLTV_GRABBER |The name of the xmltv grabber you want to use (default=tv_grab_eu_xmltvse)| ```-e 'tv_grab_dk_meetv'```
|XMLTV_DAYS |The number of days you want to grab (default=7) | ```-e '3'```

### Generate xmltv configuration file

Use this step to run xmltv configuration script and generate the configuration file.

If you already have a xmltv grabber configuration file in the container 'work-dir' on your host you can skip this.

**Create and run temporary container (edit the volume mount):**

```
sudo docker container run --rm -i \
-v '/volume1/docker/xmltv/container:/root/.xmltv' \
kibuan/xmltv
```

Follow the instructions in the xmltv setup guide. When the container exits you should see the .conf file in your mounted folder on the host.

### Test run (download tv data and create output xml file)

**Setup both the mounts and run the container:**

```
sudo docker container run --rm -i \
-v '/volume1/docker/xmltv/container:/root/.xmltv' \
-v '/volume1/docker/xmltv/container:/opt/xml' \
kibuan/xmltv
```

When the container exits the .xml file should be ready in the output folder.

### Schedule daily update
Create a bash script on your docker host that runs the container daily to update your xmltv tv guide. Use your docker hosts scheduler to run the script daily.

Example script:
```
#!/bin/bash
sudo docker container run --rm -i \
-v '/volume1/docker/xmltv/container:/root/.xmltv' \
-v '/volume1/docker/xmltv/container:/opt/xml' \
-e 'XMLTV_DAYS=14' \
kibuan/xmltv
```

# Setup xmltv guide on Plex

Follow [this guide](https://support.plex.tv/articles/using-an-xmltv-guide/) to setup Plex DVR to use your local xmltv.xml file.
