# Kafka Schema Registry MCP Demo Deployment

🚀 **Complete demo environment for the Kafka Schema Registry MCP Server**

This repository contains everything needed to deploy a comprehensive demo showcasing the capabilities of the [Kafka Schema Registry MCP Server](https://github.com/aywengo/kafka-schema-reg-mcp) with OAuth authentication, multi-registry support, and real-world use cases.

## 🎯 What This Demo Showcases

### Core Features
- **Multi-Registry Management** - Development, Staging, and Production environments
- **OAuth Authentication** - Role-based access control with different permission levels  
- **Schema Contexts** - Logical organization for different business domains
- **Real-World Use Cases** - E-commerce, IoT, Financial Services, and Multi-tenant SaaS
- **Integration Examples** - Claude Desktop, VSCode, and Cursor configurations
- **Enterprise Features** - Migration, export, governance, and audit capabilities

### Architecture Overview
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging      │    │   Production    │
│   Registry      │    │    Registry      │    │    Registry     │
│   :8081         │    │     :8082        │    │     :8083       │
│   (Full Access) │    │ (Limited Write)  │    │   (Read-Only)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────────────┐
                    │       MCP Server        │
                    │   (Multi-Registry)      │
                    │   OAuth Enabled         │
                    │      :38000             │
                    └─────────────────────────┘
                                 │
                    ┌─────────────────────────┐
                    │    OAuth Provider       │
                    │     (Keycloak)          │
                    │       :8080             │
                    └─────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- 8GB+ RAM recommended
- Ports 3000, 8080-8083, 9090-9092, 38000 available

### 1. Clone and Start
```bash
# Clone the repository
git clone https://github.com/aywengo/demo-deployment.git
cd demo-deployment

# Start the complete demo environment
docker-compose up -d

# Wait for all services to be healthy (2-3 minutes)
docker-compose ps
```

### 2. Access the Demo

| Service | URL | Purpose |
|---------|-----|----------|
| **MCP Server** | http://localhost:38000 | Main MCP server API |
| **OAuth Provider** | http://localhost:8080 | Keycloak admin (admin/admin123) |
| **Dev Registry** | http://localhost:8081 | Development schema registry |
| **Staging Registry** | http://localhost:8082 | Staging schema registry |
| **Production Registry** | http://localhost:8083 | Production schema registry |
| **Monitoring** | http://localhost:9090 | Prometheus metrics |
| **Dashboards** | http://localhost:3001 | Grafana dashboards (admin/admin123) |

### 3. Test the Setup
```bash
# Test MCP server health
curl http://localhost:38000/health

# List all registries
curl http://localhost:38000/registries

# Test OAuth scopes info
curl -H "Authorization: Bearer dev-token-read,write,admin" \
     http://localhost:38000/oauth/scopes
```

## 🎭 Demo Scenarios

### Scenario 1: E-commerce Platform
**Context**: `ecommerce`

```bash
# Register user profile schema
curl -X POST http://localhost:38000/schemas \
  -H "Authorization: Bearer dev-token-write" \
  -H "Content-Type: application/json" \
  -d '{
    "registry": "development",
    "context": "ecommerce", 
    "subject": "user-profile",
    "schema": {
      "type": "record",
      "name": "UserProfile",
      "fields": [
        {"name": "id", "type": "string"},
        {"name": "email", "type": "string"},
        {"name": "name", "type": "string"},
        {"name": "created_at", "type": "long"}
      ]
    }
  }'
```

### Scenario 2: Multi-Registry Migration

```bash
# Migrate schema from dev to staging
curl -X POST http://localhost:38000/migrate \
  -H "Authorization: Bearer dev-token-admin" \
  -H "Content-Type: application/json" \
  -d '{
    "source_registry": "development",
    "target_registry": "staging",
    "subject": "user-profile",
    "source_context": "ecommerce",
    "target_context": "ecommerce",
    "migrate_all_versions": true
  }'
```

### Scenario 3: OAuth Role Testing

```bash
# Test read-only access
curl -H "Authorization: Bearer dev-token-read" \
     http://localhost:38000/schemas/user-profile

# Try admin operation (requires admin token)
curl -X DELETE http://localhost:38000/contexts/test-context \
  -H "Authorization: Bearer dev-token-admin"
```

## 🔧 Integration Examples

### Claude Desktop Configuration

Add this to your Claude Desktop config:

```json
{
  "mcpServers": {
    "kafka-schema-registry-demo": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "kafka-schema-mcp-demo",
        "-e", "ENABLE_AUTH=true",
        "-e", "AUTH_ISSUER_URL=http://oauth-provider:8080/realms/demo",
        "-e", "SCHEMA_REGISTRY_NAME_1=development",
        "-e", "SCHEMA_REGISTRY_URL_1=http://dev-registry:8081", 
        "-e", "SCHEMA_REGISTRY_NAME_2=staging",
        "-e", "SCHEMA_REGISTRY_URL_2=http://staging-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_3=production",
        "-e", "SCHEMA_REGISTRY_URL_3=http://prod-registry:8081",
        "-e", "READONLY_3=true",
        "-e", "OAUTH_TOKEN=dev-token-read,write,admin",
        "aywengo/kafka-schema-reg-mcp:stable"
      ]
    }
  }
}
```

## 🔒 Security Features

### OAuth Scopes and Permissions

| Scope | Permissions | Use Case |
|-------|-------------|----------|
| `read` | View schemas, subjects, configurations | Developers, analysts |
| `write` | Register schemas, update configs (+ read) | Schema developers |
| `admin` | Delete subjects, manage registries (+ write + read) | Platform administrators |

### Development Tokens
For testing and development, use special tokens:
```bash
# Full access token
export OAUTH_TOKEN="dev-token-read,write,admin"

# Read-only token  
export OAUTH_TOKEN="dev-token-read"

# Developer token (read + write)
export OAUTH_TOKEN="dev-token-write"
```

## 🧪 Testing

### Automated Testing
```bash
# Run complete health check
./scripts/health-check.sh

# Test OAuth functionality
./scripts/test-oauth.sh

# Setup demo data
./scripts/setup-demo-data.sh
```

## 🚢 Deployment Options

### Local Development
```bash
# Start development environment
docker-compose up -d
```

### Cloud Deployment

#### AWS ECS/Fargate
```bash
# Deploy to AWS using Terraform
cd terraform/aws
terraform init
terraform plan
terraform apply
```

## 📊 Monitoring and Observability

### Prometheus Metrics
- Schema registry health and performance
- MCP server request rates and latency
- OAuth authentication success/failure rates
- Schema operation counts by registry and context

### Grafana Dashboards
- **Schema Registry Overview** - Registry health, schema counts, operation rates
- **MCP Server Performance** - Request latency, error rates, OAuth metrics
- **Business Metrics** - Schema registrations by context, compatibility check results

## 🔧 Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check service logs
docker-compose logs oauth-provider
docker-compose logs mcp-server

# Restart problematic services
docker-compose restart oauth-provider
```

#### OAuth Authentication Failures
```bash
# Check Keycloak realm configuration
curl http://localhost:8080/realms/demo/.well-known/openid_configuration

# Verify token format
echo "dev-token-read,write,admin" | base64
```

#### Schema Registry Connection Issues
```bash
# Test registry connectivity
curl http://localhost:8081/config
curl http://localhost:8082/config  
curl http://localhost:8083/config

# Check Kafka connectivity
docker exec demo-kafka kafka-topics --bootstrap-server localhost:9092 --list
```

### Getting Help
- 📖 [Full Documentation](https://github.com/aywengo/kafka-schema-reg-mcp/docs)
- 🐛 [Issue Tracker](https://github.com/aywengo/kafka-schema-reg-mcp/issues)
- 💬 [Discussions](https://github.com/aywengo/kafka-schema-reg-mcp/discussions)
- 📧 Email: [aywengo@example.com](mailto:aywengo@example.com)

## 🤝 Contributing

Contributions welcome! Please see:
- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Development Setup](docs/development.md)

## 📄 License

This demo is licensed under the [MIT License](LICENSE). The main MCP server project has its own license.

---

🌟 **Star this repository** if you find it useful!

📢 **Share your experience** - we'd love to hear how you're using the Kafka Schema Registry MCP Server!