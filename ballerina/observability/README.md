* location_service_http: bal run

* location_service_http_cached: bal run
  - geo_service_http_mem: bal run
  - geo_service_http_db: bal run

docker run -p 9090:9090 -v /home/laf/dev/samples/ballerina/observability/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
docker run -p 3000:3000 grafana/grafana
docker run -p 13133:13133 -p 16686:16686 -p 55680:55680 jaegertracing/opentelemetry-all-in-one

http://localhost:3000/
http://localhost:16686/search

Grafana dashboard id: 5841

docker run -p 15672:15672 -p 5672:5672 rabbitmq:3-management

var ws = new WebSocket("ws://localhost:8084/mylocation", "xml");
//ws.onmessage = function(frame) {console.log(frame.data)};
ws.onmessage = function(frame) {alert(frame.data)};
ws.send("location");

[ballerina.observe]
enabled=true

import ballerinax/prometheus as _;
import ballerinax/jaeger as _;

https://central.ballerina.io/ballerinax/choreo

import ballerinax/choreo as _;