# Deploy a Sample Container Apps Application

## Container Apps Environment
Deploy a container apps environment

### Environment Deployment
1. `chmod +x environment-deploy.sh`
2. `./environment-deploy.sh <environment_name> <location>`

Note:
- <environment_name> can be any text, lowercase alphanumeric and dashes - just make it unique enough and relevant to you (e.g. yourorg-containers-01)
- Available values for <location> can be found with the following command

	`az account list-locations --query "[].{Name:name}" -o table`

- You'll use the value for <environment_name> and the generated name for the container registry when deploying each container app.


### Container Apps Deployment

sample-app

1. `cd src/sample-app`
2. `chmod +x deploy.sh`
3. `./deploy.sh <environment_name> <container_registry_name>`

python-app

1. `cd src/python-app`
2. `chmod +x src/python-app/deploy.sh`
3. `./src/python-app/deploy.sh <environment_name> <container_registry_name>`

dotnet-api

1. `cd src/dotnet-api`
2. `chmod +x src/dotnet-api/deploy.sh`
2. `./src/dotnet-api/deploy.sh <environment_name> <container_registry_name>`