## Ballerina - Ecommerce Sample

### Populate DB
```bash
mysql -u user -p < db.sql
```

### Build Services and Run
```bash
cd services
ballerina build
bal run target/bin/ecommerce.jar
```

### Run Simulator
```bash
# bal run simulator.bal -- [interval milliseconds] [count]
bal run simulator.bal -- 1000 1000
```
