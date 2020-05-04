# CiGri
arion exec cigri systemctl stop cigri-rest-api.service
arion exec cigri systemctl restart my-startup.service
arion exec cigri systemctl restart cigri-rest-api.service
# OAR
arion exec node1 systemctl restart oar-node-register

arion exec cigri bash
