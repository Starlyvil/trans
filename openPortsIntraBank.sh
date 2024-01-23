
#!/bin/bash

ports=(6443 2379 2380 10250 10251 10252 10259 10257 30000 30001 30002 30003 30004 30005 30006 30007 30008 30009 30010 30011 30012 30013 30014 30015 30016 30017 30018 30019 30020)

start_listener() {
  port=$1
  nc -l -p $port &
  echo "Listening on port $port"
}
for port in "${ports[@]}"; do
  start_listener $port
done

echo "Press Ctrl+C to stop all listeners"
trap "kill 0" EXIT
wait
