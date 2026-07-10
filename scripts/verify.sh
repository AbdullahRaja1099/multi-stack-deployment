#!/usr/bin/env bash
# Sanity-checks every piece of the lab. Safe to run repeatedly.
set -uo pipefail

echo "== Service status =="
systemctl is-active apache2 tomcat nginx pyapp nodeapp

echo
echo "== App/server checks =="
curl -s -o /dev/null -w "Apache  (Python app, :8081)      -> %{http_code}\n" http://localhost:8081/
curl -s -o /dev/null -w "Tomcat  (Java app,   :8080)      -> %{http_code}\n" http://localhost:8080/javaapp/
curl -s -o /dev/null -w "Nginx   (Node app,   :80)        -> %{http_code}\n" http://localhost/
curl -s -o /dev/null -w "Nginx forward proxy (:8888)      -> %{http_code}\n" -x http://localhost:8888 http://example.com

echo
echo "== Virtual hosting =="
curl -s -o /dev/null -w "python.lab.local -> %{http_code}\n" -H "Host: python.lab.local" http://localhost/
curl -s -o /dev/null -w "java.lab.local   -> %{http_code}\n" -H "Host: java.lab.local"   http://localhost/
curl -s -o /dev/null -w "node.lab.local   -> %{http_code}\n" -H "Host: node.lab.local"   http://localhost/

echo
echo "== Domain + SSL =="
curl -s -o /dev/null -w "app.lab.local (http)  -> %{http_code}\n" http://app.lab.local/
curl -s -k -o /dev/null -w "app.lab.local (https) -> %{http_code}\n" https://app.lab.local/

echo
echo "== Context-based routing (:8090) =="
curl -s -o /dev/null -w "/python/ -> %{http_code}\n" http://localhost:8090/python/
curl -s -o /dev/null -w "/java/   -> %{http_code}\n" http://localhost:8090/java/
curl -s -o /dev/null -w "/node/   -> %{http_code}\n" http://localhost:8090/node/
