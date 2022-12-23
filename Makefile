#
# Fork of a nice CIFS/SMB/Samba docker container, configured for my purposes
#
# Written by Glen Darling (mosquito@darlingevil.com), December 2022.
#

NAME         := samba
DOCKERHUB_ID := ibmosquito
VERSION      := 1.0.0

# Set this in your shell environment before running the server (or edit here)
MY_USER_PASS    ?=terriblepassword

# Name and location of the share
MY_SHARE_NAME   :=Plex
MY_SHARE_PATH   :=/media/pi/UNTITLED/PLEXDATA

# By default, build, push, and run
default: build push

# Build my own copy
build:
	docker build -t $(DOCKERHUB_ID)/$(NAME):$(VERSION) -f Dockerfile.aarch64 .

# Run the damned thing
run: stop
	docker run -d --restart unless-stopped \
	  --name $(NAME) \
	  -e TZ="America/Los_Angeles" \
	  -e USERID=1000 \
	  -e GROUPID=1000 \
	  -p 137:137/udp \
	  -p 138:138/udp \
	  -p 139:139 \
	  -p 445:445 \
	  -v "$(MY_SHARE_PATH):/mount" \
	  $(DOCKERHUB_ID)/$(NAME):$(VERSION) \
	  -n \
	  -u "pi;$(MY_USER_PASS)" \
	  -s "$(MY_SHARE_NAME);/mount;yes;no;no;pi"

# Push the conatiner to DockerHub (you need to `docker login` first of course)
push:
	docker push $(DOCKERHUB_ID)/$(NAME):$(VERSION)

# Stop the daemon container
stop:
	@docker rm -f ${NAME} >/dev/null 2>&1 || :

# Stop the daemon container, and cleanup
clean: stop
	@docker rmi -f $(DOCKERHUB_ID)/$(NAME):$(VERSION) >/dev/null 2>&1 || :

# Declare all of these non-file-system targets as .PHONY
.PHONY: default build run push stop
