
.PHONY: install

install:
	mkdir -p /opt/omada-controller/bin
	cp -R service/opt/omada-controller/bin/* /opt/omada-controller/bin
	chmod +x /opt/omada-controller/bin/*
	cp service/usr/lib/systemd/system/omada-controller.service /usr/lib/systemd/system/
	systemctl daemon-reload
	systemd-analyze verify /usr/lib/systemd/system/omada-controller.service && sudo systemctl enable omada-controller.service && systemctl restart omada-controller.service


