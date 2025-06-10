# Software Developer Interview Assignment

### View the a working version at [http://138.197.8.225/](http://138.197.8.225/)

## Overview

![Screenshot from 2025-06-10 11-00-30](https://github.com/user-attachments/assets/87e0fe49-9bed-4611-aee1-5d70de1ff51b)

A simple web tool to search a cellphone stores inventory using specified parameters, brand, storage, color, and price.

The project includes a static HTML/CSS UI mockup with basic JavaScript for filtering and sorting results. And a GO API which returns the data from a JSON file, this could easly be replaced with a SQLite or PostgreSQL database but was deemed overkill for the purposes of this excersize.

### frontend

The frontend is a simple static HTML page that uses JavaScript and CSS

### backend

The backend is writen in Go and is built:

```bash
go build -o main.go
```

### Automation

This project uses [GitHub Actions](https://github.com/features/actions), [Terraform](https://developer.hashicorp.com/terraform) and [Ansible](https://www.redhat.com/en/ansible-collaborative) to automate the creation of a VM, and the deployment of the web app to that vm.

The GitHub action (see [.github](/.github)) triggers on push to the `main` branch and when push launches the Terraform (see [terraform](/terraform))
