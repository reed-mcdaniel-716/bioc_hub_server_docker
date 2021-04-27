---
title: "Bioconduction Hub Server Docker Deployment"
author: "Maya Reed McDaniel"
date: "4/20/2021"
output: html_document
---
## Based on the work of Lori Shepherd and the Bioconductor team

### Dockerizing the Bioconductor Hub Server
- The Bioconductor Hub Server is like a little local instances of AnnotationHub
and ExperimentHub
    - For example, if a research group wanted their own Hub instance
- The hub is a Ruby application with MySQL and SQLite databases
- See [GitHub](https://github.com/Bioconductor/BiocHubServer/tree/versioning)
on the `versioning` branch

---
#### Approach
- Created a `Dockerfile` that starts of with the Ruby image
(base is **Ubuntu buster**), and installs the following:
    - sqlite
    - MySQL client libraries
    - appropriate version of Ruby bundler
- Additionally, application source files, database scripts, and application scripts
are added in the image as well (cloned from GitHub)
- Created a `docker-compse.yaml` with a Ruby container built from the augmented
Ruby Dockerfile and a vanilla MySQL container
- Ruby container waits until the MySQL container is running to initialize the
MySQL database, apply the database migrations, and start the hub server
application, commands for which are contained in the `app.sh` file

---
#### Commands
- for bringing up the two containers which make up the hub server application;
if it doesn't already exist, this will also build the Ruby based image
```
alias biochubup='docker-compose -f docker-compose.yaml up -d && docker-compose -f docker-compose.yaml logs -f'
```

- for bringing down the containers
```
alias biochubdown='docker-compose -f docker-compose.yaml down'
```

- for direct command line access to the MySQL database container
```
alias biochubdb='docker exec -ti bioc-hub-server-db mysql --user=mrmcd --password=secretpw'
```

- for direct command line access to the Ruby based container
```
alias biochubapp='docker exec -ti bioc-hub-server-app bash'
```

- alternative way to access the MySQL database container
```
mysql --host=bioc-hub-server-db --port=3306 --user=mrmcd --password=secretpw hubserverdb
```

---
#### Notes
- The core Ruby app must be run with the host option `0.0.0.0` so that the
container is listening on all interfaces for requests and not just its own
internal localhost
- Software versions were kept as close to the original as possible, but some
tweaks were made to accommodate newer versions of Ruby and the underlying
Ubuntu image (buster)
