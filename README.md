# Personal Log

A small blogging System written in coffee-script.

## Usage
The Service only fully works with Chrome Browsers.

## Installation
Install Node and CouchDB.

Run 

 npm install

Create a File called init_config.json

This file might Look like this:
 
{
  "my_name": "mitschoko",
  "init_pass": "testtest",
  "url":   "localhost",  
  "port": 80,
  "couch_host": "localhost",
  "couch_port":  5984,
  "couch_user":  "mitschoko",
  "couch_pass":  "qwertzuiop"
}

Run 

 coffee init.coffee

The script will setup a new config.json file and create Databases at the couch server at localhost:5984 using couch_user and couch_pass to Login to the Database. It also creates an admin account named mitschoko with the pass qwertzuiop 

