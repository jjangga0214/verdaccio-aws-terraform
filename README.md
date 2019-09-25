# verdaccio-aws-terraform

A boilerplate of [verdaccio](https://github.com/verdaccio/verdaccio/) on aws with terraform.

## config

Edit `docker/conf/config.yaml` as you want. Note that it allows every actions(e.g. `publish`) without authentication as default.

## Getting started

Create and edit terraform.tfvars with your configuration.

```bash
cp terraform.tfvars.example terraform.tfvars
```

Provison from aws.

```bash
terraform init
terraform apply
```

Terraform would print ip. The default port is 4873 if not editted.
Now you can use verdaccio as private npm registry like this.

```bash
npm publish --registry=http://<your-ec2-ip>:4873
npm install <your package> --registry=http://<your ec2 ip>:4873
```