# Makefile ------+
# Version: 0.0.6 |
# ---------------+
# vim: noai:ts=2

### VARIABLES
# -----------
override REGISTRY = ff0x
override SKIP_ARM = true

### INCLUDES
# ----------
include ../@include/default.mk

### CONTAINER
# -----------
run: clean test add-s3-secret logs

test:
	docker run --platform linux/${DEF_ARCH} --name ${LABEL} --hostname ${LABEL}.${DOMAIN} -e SSH_USER="$(shell whoami)" -e SSH_KEY="$(shell cat ~/.ssh/id_rsa.pub)" -v ssh-hostkeys:/etc/dropbear -v ${LABEL}-data:/var/lib/git --publish=3333:22 -d $(NAME)
	@sleep 2

add-s3-secret:
	@printf "accesskey: %s\nsecretkey: %s\nacl: %s\nregion: %s\ndomain: %s\n" "$(shell pass show web/wasabisys.com/api_access_key_git)" "$(shell pass show web/wasabisys.com/api_secret_key_git)" "private" "eu-central-1" "s3.eu-central-1.wasabisys.com" | docker exec -i ${LABEL} sh -c 'umask 0022; cat >/var/lib/git/.wasabi'

clean:
	docker kill ${LABEL} >/dev/null 2>&1 || true
	docker rm ${LABEL} >/dev/null 2>&1 || true
	docker volume rm ssh-hostkeys >/dev/null 2>&1 || true
	docker volume rm gitolite-data >/dev/null 2>&1 || true

debug: clean
	docker run -ti --entrypoint /bin/bash --platform linux/${DEF_ARCH} --name ${LABEL} --hostname ${LABEL}.${DOMAIN} -e SSH_USER="$(shell whoami)" -e SSH_KEY="$(shell cat ~/.ssh/id_rsa.pub)" -v ssh-hostkeys:/etc/dropbear -v ${LABEL}-data:/var/lib/git --publish=3333:22 -d $(NAME)
	@sleep 2
	docker exec -ti ${LABEL} /bin/bash
