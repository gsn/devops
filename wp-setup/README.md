Wordpress Setup
==================
To support GSN requirement, this is a modified version of Easy Engine: https://github.com/rtCamp/easyengine

#Intro
Easy Engine is a flexible boilerplate for supporting single server WordPress.  GSN PaaS required that we only use a subset of this features; therefore, this code was simplified to have the following function/configurations:

- Multi-site with sub-domain
- W3tc total cache plug-in optimize
- Stripped down EasyEngine administrative UI
- Single WordPress Administrative server
- Clustered Worker servers
- Run on Amazon AWS