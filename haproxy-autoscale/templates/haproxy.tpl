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
  maxconn     8192                    #This is not the same as request/s
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
  option                  dontlognull           #Dont empty log record
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

  errorfile  400 /etc/haproxy/errors/400.http
  errorfile  403 /etc/haproxy/errors/403.http
  errorfile  408 /etc/haproxy/errors/408.http
  errorfile  500 /etc/haproxy/errors/500.http
  errorfile  502 /etc/haproxy/errors/502.http
  errorfile  503 /etc/haproxy/errors/503.http
  errorfile  504 /etc/haproxy/errors/504.http

#---------------------------------------------------------------------
# enable stats service
#---------------------------------------------------------------------
listen stats :1988
  stats enable
  stats refresh 2s
  stats show-legends                         
  stats show-legends
  stats realm Haproxy\ Statistics
  stats uri /
  stats auth showme:showme # should disable port after viewing stat
  
#---------------------------------------------------------------------
# enable stats service
#---------------------------------------------------------------------
listen stat-in :46317
  reqadd Proxy-Authorization:\ Basic\ Z3NuZW5naW5lOmdzbmVuZ2luZQ==
  default_backend stat-backend
  
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend http-in
  bind        0.0.0.0:80
  reqadd      X-Forwarded-Proto:\ http
  
  # Use General Purpose Couter (gpc) 0 in SC1 as a global abuse counter
  # Monitors the number of request sent by an IP over a period of 10 seconds
  # stick-table type ip size 1m expire 10s store gpc0,http_req_rate(10s),http_err_rate(10s)
  
  # Allow clean known IPs to bypass the filter, remember to add CDN ips (maxcdn)
  # tcp-request connection accept if { src -f /etc/haproxy/whitelist.lst }
  
  # Shut the new connection as long as the client has already 200 opened
  # 200 is a generous number to support corporate browsing scenario
  # tcp-request connection track-sc1 src
  # tcp-request connection reject if { src_get_gpc0 gt 200 }

  # If the source IP sent 2000 or more http request over the defined period,
  # flag the IP as abuser on the frontend
  # acl abuse src_http_req_rate(ft_web) ge 2000
  # acl flag_abuser src_inc_gpc0(ft_web)
  # tcp-request content reject if abuse flag_abuser
  # http-request deny if abuse flag_abuser
  
  # define wp-admin url acl
  acl url_wp_admin1 hdr_end(host) -i gsn2.com
  acl url_wp_admin2 hdr_end(host) -i gsngrocers.com
  acl url_wp_admin3 hdr_end(host) -i gsn.io
  acl url_wp_admin4 path_beg -i /wp-admin
  acl url_wp_admin5 path_beg -i /wp-login
  
  use_backend wp-admin if url_wp_admin1 or url_wp_admin2 or url_wp_admin3 or url_wp_admin4 or url_wp_admin5 
  default_backend wp-workers
    
#---------------------------------------------------------------------
# static backend for serving up admin, images, stylesheets and such
#---------------------------------------------------------------------
backend wp-admin
  server wp-instance-admin 0.0.0.0:8000 maxconn 400 check

#---------------------------------------------------------------------
# round robin balancing between the various worker backends
#---------------------------------------------------------------------
backend wp-workers
  balance roundrobin
  # cookie  SERVERID insert indirect
  % for instance in instances['security-group-1']:
  server ${ instance.id } ${ instance.private_dns_name }:8000 maxconn 200 check
  % endfor

#---------------------------------------------------------------------
# open one worker for server-admin
#---------------------------------------------------------------------
backend stat-backend
  % for instance in instances['security-group-1']:
  server ${ instance.id } ${ instance.private_dns_name }:46317 maxconn 10 check
  break
  % endfor
