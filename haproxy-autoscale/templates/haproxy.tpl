global  
    daemon
    maxconn 256

defaults
	log     global
	mode    http
	option  httplog
	option  dontlognull
	contimeout 5000
	clitimeout 50000
	srvtimeout 50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend www *:80
    mode http
    maxconn 50000
    acl url_wordpress path_reg ^([^\ :]*)\ /wp-(admin|login)/(.*)
	use_backend wp-admin-backend if url_wordpress
	default_backend servers
	
backend wp-admin-backend
    mode http
	server wordpress-1 127.0.0.1:80 check

backend servers
    mode http
    balance roundrobin
    % for instance in instances['wpa-secgrp-app']:
    server ${ instance.id } ${ instance.private_dns_name }
    % endfor


