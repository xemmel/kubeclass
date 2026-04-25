## Linux Services

```bash

sudo tee /etc/systemd/system/hello.service > /dev/null <<EOF
[Unit]
Description=My First Service

[Service]
Type=oneshot
ExecStart=/bin/echo "Hello from systemd!"

[Install]
WantedBy=multi-user.target
EOF

systemctl list-units --type=service | grep hello

sudo systemctl daemon-reload

sudo systemctl start hello.service

systemctl status hello.service



## Cleanup

sudo systemctl stop hello.service

## If you enabled it
sudo systemctl disable hello.service

sudo rm /etc/systemd/system/hello.service

sudo systemctl daemon-reload

```