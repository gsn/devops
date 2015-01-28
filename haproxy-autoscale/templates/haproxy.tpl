global   #The global configuration file
  # to have these messages end up in /var/log/haproxy.log you will
  # need to:     #Configure log
  #
  # 1) configure syslog to accept network log events.  This is done
  #    by adding the '-r' option to the SYSLOGD_OPTIONS in
  #    /etc/sysconfig/syslog    #Modify the syslog configuration file
  #
  # 2) configure local2 events to go to the /var/log/haproxy.log
  #   file. A line like the following can be added to
  #   /etc/sysconfig/syslog    #The definition of log device
  #
  #    local2.*                       /var/log/haproxy.log
  #
  log         127.0.0.1 local2        #Log configuration, all log records the local, through the Local2 output

  chroot      /var/lib/haproxy        #Change the haproxy working directory.
  pidfile     /var/run/haproxy.pid    #Specifies the path to the PID file
  maxconn     100000                  #Attempt to hit 100K req/s
  user        haproxy                 #The specified operation service users
  group       haproxy                 #The user specified set of operation service
  daemon

  # turn on stats unix socket
  stats       socket /var/lib/haproxy/stats

  # spread health check to avoid sending agent and health checks to servers at exact intervals
  spread-checks 5 

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
  mode                    http                  #Set http as default protocol
  log                     global                #Global logging
  option                  httplog               #With the HTTP log records
  option                  dontlognull           #Don't empty log record
  option http-server-close     
  option abortonclose    
  option forwardfor       except 127.0.0.0/8    #From these information are not forwardfor
  option                  redispatch            #Any server can handle any session
  retries                 3                     #The 3 connection failure is that the service is not available
  timeout http-request    10s                   #The default HTTP request timeout
  timeout queue           1m                    #The default queue timeout
  timeout connect         10s                   #The default connection timeout
  timeout client          1m                    #Default client timeout
  timeout server          1m                    #The default server timeout
  timeout http-keep-alive 10s                   #Default persistence connection timeout
  timeout check           10s                   #The default check interval
  maxconn                 100000                #Attempt to hit 100K req/s

  errorfile  400 /etc/haproxy/errors/400.http
  errorfile  403 /etc/haproxy/errors/403.http
  errorfile  408 /etc/haproxy/errors/408.http
  errorfile  500 /etc/haproxy/errors/500.http
  errorfile  502 /etc/haproxy/errors/502.http
  errorfile  503 /etc/haproxy/errors/503.http
  errorfile  504 /etc/haproxy/errors/504.http
  
  # enable compression (haproxy v1.5-dev13 and above required)
  compression algo gzip
  compression type text/html application/javascript text/css application/x-javascript text/javascript

#---------------------------------------------------------------------
# enable stats service
#---------------------------------------------------------------------
listen stats :1988
  stats enable
  stats hide-version
  stats show-legends
  stats scope .
  stats realm Haproxy\ Statistics
  stats uri /
  stats auth showme:showme # should disable port after viewing stat
  
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend http-in
  bind        *:80
  reqadd      X-Forwarded-Proto:\ http
  
  #stick-table type ip size 1m expire 1m store gpc0,http_req_rate(10s),http_err_rate(10s)
  #tcp-request connection track-sc1 src
  #tcp-request connection reject if { src_get_gpc0 gt 0 }
  #http-request deny if { src_get_gpc0 gt 0 }
  
  #acl abuse src_http_req_rate(incoming) ge 700
  #acl flag_abuser src_inc_gpc0(incoming)
  #tcp-request content reject if abuse flag_abuser
  #http-request deny if abuse flag_abuser

  # define wp-admin url acl
  acl url_wp_admin1 hdr_end(host) -i gsn2.com
  acl url_wp_admin2 hdr_end(host) -i gsngrocers.com
  acl url_wp_admin3 hdr_end(host) -i gsn.io
  acl url_wp_admin4 path_beg -i /wp-admin
  acl url_wp_admin5 path_beg -i /wp-login
  
  use_backend wp-admin if url_static url_wp_admin1 url_wp_admin2 url_wp_admin3 url_wp_admin4 url_wp_admin5 
  default_backend wp-workers
    
#---------------------------------------------------------------------
# static backend for serving up admin, images, stylesheets and such
#---------------------------------------------------------------------
backend wp-admin
  server wp-instance-admin 127.0.0.1:8000 check

#---------------------------------------------------------------------
# round robin balancing between the various worker backends
#---------------------------------------------------------------------
backend wp-workers
  balance roundrobin
  cookie  SERVERID insert indirect
  % for instance in instances['security-group-1']:
  server ${ instance.id } ${ instance.private_dns_name }
  % endfor
  
