# QGIS Keycloak Login Website

This repository contains the setup for our login service using Keycloak.

## Development setup

- Clone the repository and enter the directory:
```sh
git clone https://
cd QGIS-Login-Website
```

- Generate, edit the .env file:
```sh
cp env.template .env
vim .env
```
Make sure to set the KEYCLOAK_COMMAND value to start-dev.

- Run the project:
```sh
make start-dev
```

## Production setup

Clone the repo and generate the .env file as done in the [Development](#development-setup) section above. Edit the .env with the production values and make sure to set the KEYCLOAK_COMMAND value to start.


- Run the project:
```sh
make start-dev
```
