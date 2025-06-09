# Software Developer Interview Assignment

## Overview

A simple web tool to search a cellphone stores inventory using specified parameters, brand, storage, color, and price.

The project includes a static HTML/CSS UI mockup with basic JavaScript for filtering and sorting results. And a GO API which returns the data from a JSON file, this could easly be replaced with a SQLite or PostgreSQL database but was deemed overkill for the purposes of this excersize.

## Development Notes

The frontend and simple GO API were chose to show applicable skills, namely the ability to take a given set of requierments and produce a working MVP to present to users to get feedback in order to develope the tool in an agile manor to best meet the users needs.

The use of GO for the backend was chosen because of it's use with in NY CREATES for the new intranet.

Lastly I wrote a github action to spin up a VM in Digital Ocean using OpenTofu (this could easily be changed to any other infrastructure platform be it cloud or on prem) and then configure the system and deploy the web application. Subsequent runs of the github action only update the deployed app.


### Security notes:

Right now the API key is hardcoded in a .env file, but this could easily be tied into a user login flow where on login an api key for that user is returned in the session alowwing for better tracking of API calls.

To limit the attack surface the API only responds to POST or Option requests

	// return one response for both an empty key and an invalid key to provide less information to potentail advisaries
