# RDN
RDN Connector

# Docker
```bash
- Build container
docker-compose build --no-cache rdn_connector

- Open Container terminal
docker-compose run --rm rdn_connector bash
```

# Build connector
```bash
ruby build.rb
```

# Run tests
```bash
rspec rdn_library_spec.rb
bundle exec rspec
```

# Deploy
```bash
workato push
```