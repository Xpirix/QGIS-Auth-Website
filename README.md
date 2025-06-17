# QGIS Keycloak Auth Website

This repository contains the setup for our auth service using Keycloak.

## Development setup

- Clone the repository and enter the directory:
```sh
git clone https://github.com/Xpirix/QGIS-Auth-Website.git
cd QGIS-Auth-Website
```

- Generate, edit the .env file:
```sh
cp env.template .env
vim .env
```
Make sure to set the KEYCLOAK_COMMAND value to start-dev.

- Run the project:
```sh
make devweb
```

On your browser, visit http://localhost:8081

## Production setup

Clone the repo and generate the .env file as done in the [Development](#development-setup) section above. Edit the .env with the production values and make sure to set the KEYCLOAK_COMMAND value to start.


- Run the project:
```sh
make web
```
