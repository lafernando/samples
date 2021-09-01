## Ballerina - Ecommerce Sample

### Populated DB, build services and run
```bash
cd services
mysql -u user -p < db.sql
bal build
bal run target/bin/ecommerce.jar
```

### Build and Run Simulator
```bash
cd simulator
bal build
# bal run target/bin/simulator.jar -- [interval milliseconds] [iterations]
bal run target/bin/simulator.jar -- 100 1000
```
