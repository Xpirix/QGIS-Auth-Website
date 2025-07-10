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

## Custom themes

The `themes` folder is based on the Keycloakify repo https://github.com/keycloakify/keycloakify-starter.

### Quick start

Run the keycloakify storybook with:
```sh
cd themes
npm install
npm run storybook
```
This will spin up the storybook on your local at  http://localhost:6006/.

### Add story

```sh
npx keycloakify add-story
```

### Build the theme
The following command will build the theme and create two `.jar` files in `dist_keycloak`.
We only commit the `keycloak-theme-for-kc-all-other-versions.jar` as we are using the version 26+
The folder is mounted to the keycloak service with docker-compose volume.
```sh
npm run build-keycloak-theme
```
Please refere to the [README](./themes/README.md) and the [online docs](https://docs.keycloakify.dev) for more details.

## Production setup

Clone the repo and generate the .env file as done in the [Development](#development-setup) section above. Edit the .env with the production values and make sure to set the KEYCLOAK_COMMAND value to start.


- Run the project:
```sh
make web
```
