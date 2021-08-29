## Ballerina - Ecommerce Sample

### Populated DB, build services and run
```bash
cd services
mysql -u user -p < db.sql
ballerina build
bal run target/bin/ecommerce.jar
```

### Run Simulator
```bash
# bal run simulator.bal -- [interval milliseconds] [count]
bal run simulator.bal -- 100 1000
```
