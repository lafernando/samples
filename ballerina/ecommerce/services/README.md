## Ballerina - Ecommerce Sample

### Commands

```bash
mysql -u user -p < db.sql

ballerina build -a

ballerina run target/bin/cart.jar --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9797
ballerina run target/bin/ordermgt.jar --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9798
ballerina run target/bin/billing.jar --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9799
ballerina run target/bin/shipping.jar --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9800
ballerina run target/bin/inventory.jar --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9801
ballerina run target/bin/admin.jar --b7a.observability.enabled=true --b7a.observability.metrics.prometheus.port=9802

docker run -p 5775:5775/udp -p6831:6831/udp -p6832:6832/udp -p5778:5778 -p16686:16686 -p14268:14268 jaegertracing/all-in-one:latest
docker run -p 9090:9090 -v /home/laf/dev/samples/ballerina/ecommerce/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
docker run -p 3000:3000 grafana/grafana

ballerina run target/bin/simulation.jar 100 1000
```

### URLs
 - Jaeger: http://localhost:16686/
 - Grafana: http://localhost:3000/
 - Ballerina/Grafana Dashboard: https://grafana.com/dashboards/5841
