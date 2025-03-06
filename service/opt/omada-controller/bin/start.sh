#!/usr/bin/env bash

VERSION="${VERSION:-5.15.8.2}"

IMAGE="mbentley/omada-controller:${VERSION}"

echo "Pulling image: ${IMAGE}"
docker pull ${IMAGE}

echo "Setting up omada user"
getent passwd omada || ( \
	useradd -g 508 -u 508 --system --shell /usr/sbin/nologin -M omada && \
	groupadd -g 508 --system omada \
)

echo "Setting up certs"
sudo mkdir -p /srv/omada/cert
cp /etc/letsencrypt/live/srvr.farm/fullchain.pem /srv/omada/cert/
cp /etc/letsencrypt/live/srvr.farm/privkey.pem /srv/omada/cert/
chmod -R 755 /srv/omada/cert
chown -R omada:omada /srv/omada/cert

echo "Setting up directories"
mkdir -p /srv/omada/data
mkdir -p /var/log/omada
chown -R omada:omada /srv/omada/data /var/log/omada


echo "Starting omada-controller"
docker container rm -f omada-controller 2>/dev/null || true;
docker run --rm --name omada-controller \
	--stop-timeout 60 \
	--privileged \
	--network host \
	--ulimit nofile=4096:8192 \
	-e MANAGE_HTTP_PORT=8088 \
	-e MANAGE_HTTPS_PORT=8043 \
	-e PGID="508" \
	-e PORTAL_HTTP_PORT=8088 \
	-e PORTAL_HTTPS_PORT=8843 \
	-e PORT_ADOPT_V1=29812 \
	-e PORT_APP_DISCOVERY=27001 \
	-e PORT_DISCOVERY=29810 \
	-e PORT_MANAGER_V1=29811 \
	-e PORT_MANAGER_V2=29814 \
	-e PORT_TRANSFER_V2=29815 \
	-e PORT_RTTY=29816 \
	-e PORT_UPGRADE_V1=29813 \
	-e PUID="508" \
	-e SHOW_SERVER_LOGS=true \
	-e SHOW_MONGODB_LOGS=false \
	-e SSL_CERT_NAME="fullchain.pem" \
	-e SSL_KEY_NAME="privkey.pem" \
	-e TZ=Etc/UTC \
	-v /srv/omada/data:/opt/tplink/EAPController/data \
	-v /var/log/omada:/opt/tplink/EAPController/logs \
	-v /srv/omada/cert:/cert \
	${IMAGE} ;

