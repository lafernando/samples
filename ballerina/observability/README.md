location_service_v1: bal run

ballerina run location_service_v2.bal --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9797
ballerina run geo_service_v1.bal --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9798
geo_service_v2: ballerina run geo_service --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9798

geo_service_v2: ballerina run geo_service_grpc --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9799
geo_service_v2: ballerina run geo_service_rabbitmq --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9800
location_service_v3: ballerina run location_service --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9801

docker run -p 9090:9090 -v /home/laf/dev/samples/ballerina/observability/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
docker run -p 3000:3000 grafana/grafana
docker run -p 13133:13133 -p 16686:16686 -p 55680:55680 jaegertracing/opentelemetry-all-in-one

Grafana dashboard id: 5841

docker run -p 15672:15672 -p 5672:5672 rabbitmq:3-management

ballerina run location_service_v4.bal --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9802

var ws = new WebSocket("ws://localhost:8084/basic/ws", "xml", "my-protocol");
ws.onmessage = function(frame) {console.log(frame.data)};
ws.send("location");

@Observable - fib(n)
