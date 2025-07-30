# Kafka Schema Registry MCP Demo - GitHub OAuth Edition

🚀 **Complete demo environment for the Kafka Schema Registry MCP Server with GitHub OAuth**

This repository contains everything needed to deploy a comprehensive demo showcasing the capabilities of the [Kafka Schema Registry MCP Server](https://github.com/aywengo/kafka-schema-reg-mcp) with **GitHub OAuth authentication**, multi-registry support, and **compatibility with any MCP-enabled IDE or AI assistant**.

## 🎯 What's New

### Latest Features (v2.1.1)
- **🚀 SLIM_MODE Performance**: Reduced tool count from 57+ to ~9 essential tools for optimal LLM performance
- **🤖 Enhanced Schema Migration**: Smart migration with user preference elicitation
- **💾 Automatic Backups**: Pre-migration backup creation
- **✅ Post-Migration Verification**: Comprehensive schema validation
- **🔒 Security Enhancements**: SSL/TLS certificate verification, secure logging

### GitHub OAuth Integration
- **Developer-Friendly**: Most developers already have GitHub accounts
- **Simplified Setup**: No need to run separate OAuth provider
- **Real OAuth Flows**: Authentic OAuth experience developers understand
- **Organization Integration**: Natural fit with GitHub organization membership
- **Production Ready**: Battle-tested OAuth provider

### OAuth Scopes Mapping
| GitHub Scope | MCP Permission | Description |
|--------------|----------------|-------------|
| `public_repo` | `read` | View public schemas and configurations |
| `repo` | `write` | Register schemas, update configs (+ read) |
| `admin:org` | `admin` | Delete subjects, manage registries (+ write + read) |

## 🔌 MCP Client Compatibility

The **Model Context Protocol (MCP)** ensures this demo works seamlessly with any MCP-compatible client:

### **🎨 Supported AI Clients & IDEs**

<table>
<tr>
<td width="25%" align="center">
<h4>🤖 Claude Desktop</h4>
<p><strong>Status:</strong> ✅ Full Support</p>
<ul>
<li>Native MCP integration</li>
<li>Natural language commands</li>
<li>Multi-registry support</li>
<li>GitHub OAuth integration</li>
</ul>
</td>
<td width="25%" align="center">
<h4>💻 VS Code + Copilot</h4>
<p><strong>Status:</strong> ✅ Agent Mode (Preview)</p>
<ul>
<li>GitHub Copilot agent mode</li>
<li>Workspace/user configuration</li>
<li>Tool integration in chat</li>
<li>Auto-discovery support</li>
</ul>
</td>
<td width="25%" align="center">
<h4>⚡ Cursor IDE</h4>
<p><strong>Status:</strong> ✅ Full Support</p>
<ul>
<li>One-click MCP installation</li>
<li>Project/global configuration</li>
<li>Agent & Composer modes</li>
<li>OAuth server support</li>
</ul>
</td>
<td width="25%" align="center">
<h4>🧠 JetBrains IDEs</h4>
<p><strong>Status:</strong> ✅ Full Support (2025.1+)</p>
<ul>
<li>IntelliJ IDEA, PyCharm, WebStorm</li>
<li>AI Assistant integration</li>
<li>Codebase-mode support</li>
<li>MCP proxy support</li>
</ul>
</td>
</tr>
</table>

### **🌐 Additional MCP Clients**
- **Microsoft Copilot Studio**: Enterprise-grade MCP integration
- **Eclipse IDE**: Copilot with MCP support  
- **Xcode**: GitHub Copilot agent mode
- **Emacs**: MCP client with gptel/llm integration
- **Warp Terminal**: AI-powered terminal with MCP
- **And many more**: [See full list →](https://modelcontextprotocol.io/clients)

## 🏗️ Architecture Overview
```
┌─────────────────────────────────────────────────────────────────┐
│                     MCP-Compatible Clients                      │
│  Claude Desktop │ VS Code Copilot │ Cursor │ JetBrains │ Others │
└─────────────────────┬───────────────────────────────────────────┘
                      │ MCP Protocol
┌─────────────────────▼───────────────────────────────────────────┐
│              MCP Server (GitHub OAuth + SLIM_MODE)              │
│  ┌─────────────┐ ┌─────────────┐  ┌─────────────┐ ┌──────────┐  │
│  │   Schema    │ │  Context    │  │   Config    │ │   Mode   │  │
│  │ Management  │ │ Management  │  │ Management  │ │ Control  │  │
│  └─────────────┘ └─────────────┘  └─────────────┘ └──────────┘  │
└─────────────┬───────────────┬───────────────┬───────────────────┘
              │               │               │
    ┌─────────▼─────────┐ ┌───▼────────┐ ┌───▼──────────┐
    │   Development     │ │  Staging   │ │ Production   │
    │   Registry        │ │  Registry  │ │   Registry   │
    │   :8081           │ │   :8082    │ │    :8083     │
    │ (Full Access)     │ │ (Limited)  │ │ (Read-Only)  │
    └───────────────-───┘ └────────────┘ └──────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- GitHub account
- **Any MCP-compatible IDE/AI client** (see supported clients above)
- 6GB+ RAM (reduced from 8GB - no Keycloak needed!)
- Ports 3000, 8081-8083, 9090-9092, 38000 available

### 1. Create GitHub OAuth App

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - **Application name**: `Kafka Schema Registry MCP Demo`
   - **Homepage URL**: `http://localhost:3000`
   - **Authorization callback URL**: `http://localhost:38000/auth/callback`
4. Copy the **Client ID** and **Client Secret**

### 2. Clone and Configure
```bash
# Clone the repository
git clone https://github.com/kafka-schema-reg-mcp-demos/demo-deployment.git
cd demo-deployment

# Create environment file
cp .env.example .env

# Edit .env with your GitHub OAuth credentials
vim .env  # Add your GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
```

### 3. Start the Demo
```bash
# Start the complete demo environment
docker-compose -f docker-compose.github-oauth.yml up -d

# Wait for services to be ready (1-2 minutes, faster without Keycloak!)
docker-compose ps
```

### 4. Load Demo Data
```bash
# Populate with realistic demo schemas
./scripts/setup-demo-data.sh
```

## 🚀 Performance Optimization with SLIM_MODE

The demo runs with **SLIM_MODE** enabled by default for optimal performance:

### What is SLIM_MODE?
- **Reduces tool count** from 57+ to ~9 essential tools
- **Significantly faster** LLM response times
- **Lower token usage** and reduced costs
- **Ideal for demos** and production read-only operations

### Essential Tools Available in SLIM_MODE:
- ✅ Schema registration and compatibility checking
- ✅ Context creation and management
- ✅ Basic export operations
- ✅ Registry management and statistics
- ✅ All read operations through resources

### To Access Full Feature Set:
```bash
# Set SLIM_MODE=false in .env to access all 57+ tools
# Useful for advanced operations like migrations and bulk updates
SLIM_MODE=false
```

## 🔐 GitHub OAuth Authentication Flow

### User Experience
1. **Access Demo**: Visit http://localhost:3000
2. **Login with GitHub**: Click "Sign in with GitHub"
3. **Authorize Application**: Grant permissions to the demo app
4. **Access Based on Permissions**: Different features based on GitHub scopes

### Permission Levels
```bash
# Public Repository Access (Read-Only)
# GitHub users with public_repo scope
curl -H "Authorization: Bearer github_token_public" \
  http://localhost:38000/subjects

# Private Repository Access (Read + Write)
# GitHub users with repo scope  
curl -X POST http://localhost:38000/schemas \
  -H "Authorization: Bearer github_token_repo" \
  -d '{"registry":"development","subject":"test","schema":{"type":"string"}}'

# Organization Admin (Full Access)
# GitHub organization owners/admins
curl -X DELETE http://localhost:38000/subjects/test \
  -H "Authorization: Bearer github_token_admin"
```

## 🎭 Demo Scenarios with GitHub OAuth

### Scenario 1: Open Source Contributor (public_repo)
**Persona**: Community member contributing to public schemas

```bash
# Login as GitHub user with public_repo access
# Can view all public schemas and registries
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  http://localhost:38000/subjects?registry=development

# Can export schemas for documentation
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  "http://localhost:38000/export/schema/user-profile?registry=development&context=ecommerce"
```

### Scenario 2: Development Team Member (repo)
**Persona**: Team member working on schema evolution

```bash
# Can register and modify schemas
curl -X POST http://localhost:38000/schemas \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -d '{
    "registry": "development",
    "context": "ecommerce",
    "subject": "product-events",
    "schema": {
      "type": "record",
      "name": "ProductEvent",
      "fields": [
        {"name": "product_id", "type": "string"},
        {"name": "event_type", "type": "string"},
        {"name": "timestamp", "type": "long"}
      ]
    }
  }'

# Can test compatibility
curl -X POST http://localhost:38000/compatibility \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -d '{...schema_evolution...}'
```

### Scenario 3: Platform Administrator (admin:org)
**Persona**: Organization owner managing production schemas

```bash
# Can manage production registries (requires SLIM_MODE=false)
curl -X POST http://localhost:38000/migrate \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -d '{
    "source_registry": "staging",
    "target_registry": "production",
    "subject": "user-profile",
    "migrate_all_versions": true
  }'

# Can delete subjects (with admin permissions)
curl -X DELETE "http://localhost:38000/subjects/old-schema?registry=development" \
  -H "Authorization: Bearer $GITHUB_TOKEN"
```

## 🌟 GitHub Organization Integration

### Organization-Based Access Control
```yaml
# .env configuration
GITHUB_ORG=kafka-schema-reg-mcp-demos
GITHUB_TEAM_READ=community
GITHUB_TEAM_WRITE=developers  
GITHUB_TEAM_ADMIN=maintainers
```

### Team Permissions
- **@kafka-schema-reg-mcp-demos/community**: Read access to all schemas
- **@kafka-schema-reg-mcp-demos/developers**: Write access to dev/staging
- **@kafka-schema-reg-mcp-demos/maintainers**: Full admin access

## 🛠️ MCP Client Configuration Examples

### Claude Desktop Configuration

```json
{
  "mcpServers": {
    "kafka-schema-registry-demo": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "kafka-schema-mcp-demo",
        "-e", "ENABLE_AUTH=true",
        "-e", "AUTH_PROVIDER=github",
        "-e", "GITHUB_CLIENT_ID",
        "-e", "GITHUB_CLIENT_SECRET",
        "-e", "GITHUB_ORG=kafka-schema-reg-mcp-demos",
        "-e", "SCHEMA_REGISTRY_NAME_1=development",
        "-e", "SCHEMA_REGISTRY_URL_1=http://dev-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_2=staging", 
        "-e", "SCHEMA_REGISTRY_URL_2=http://staging-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_3=production",
        "-e", "SCHEMA_REGISTRY_URL_3=http://prod-registry:8081",
        "-e", "VIEWONLY_3=true",
        "-e", "SLIM_MODE=true",
        "aywengo/kafka-schema-reg-mcp:stable"
      ],
      "env": {
        "GITHUB_CLIENT_ID": "your_github_client_id",
        "GITHUB_CLIENT_SECRET": "your_github_client_secret"
      }
    }
  }
}
```

### VS Code + Copilot Configuration

Create `.vscode/mcp.json` in your workspace:
```json
{
  "servers": {
    "kafka-schema-registry": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "kafka-schema-mcp-demo",
        "-e", "ENABLE_AUTH=true",
        "-e", "AUTH_PROVIDER=github",
        "-e", "SCHEMA_REGISTRY_NAME_1=development",
        "-e", "SCHEMA_REGISTRY_URL_1=http://dev-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_2=staging",
        "-e", "SCHEMA_REGISTRY_URL_2=http://staging-registry:8082",
        "-e", "SCHEMA_REGISTRY_NAME_3=production",
        "-e", "SCHEMA_REGISTRY_URL_3=http://prod-registry:8083",
        "-e", "VIEWONLY_3=true",
        "-e", "SLIM_MODE=true",
        "aywengo/kafka-schema-reg-mcp:stable"
      ],
      "env": {
        "GITHUB_CLIENT_ID": "your_github_client_id",
        "GITHUB_CLIENT_SECRET": "your_github_client_secret"
      }
    }
  }
}
```

### Cursor IDE Configuration

Create `.cursor/mcp.json` in your project:
```json
{
  "mcpServers": {
    "kafka-schema-registry": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "kafka-schema-mcp-demo",
        "-e", "ENABLE_AUTH=true", 
        "-e", "AUTH_PROVIDER=github",
        "-e", "SCHEMA_REGISTRY_NAME_1=development",
        "-e", "SCHEMA_REGISTRY_URL_1=http://dev-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_2=staging",
        "-e", "SCHEMA_REGISTRY_URL_2=http://staging-registry:8082",
        "-e", "SCHEMA_REGISTRY_NAME_3=production",
        "-e", "SCHEMA_REGISTRY_URL_3=http://prod-registry:8083",
        "-e", "VIEWONLY_3=true",
        "-e", "SLIM_MODE=true",
        "aywengo/kafka-schema-reg-mcp:stable"
      ],
      "env": {
        "GITHUB_CLIENT_ID": "your_github_client_id",
        "GITHUB_CLIENT_SECRET": "your_github_client_secret"
      }
    }
  }
}
```

### JetBrains IDEs Configuration

In **Settings → Tools → AI Assistant → Model Context Protocol (MCP)**:
```json
{
  "servers": {
    "kafka-schema-registry": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "kafka-schema-mcp-demo",
        "-e", "ENABLE_AUTH=true",
        "-e", "AUTH_PROVIDER=github",
        "-e", "SCHEMA_REGISTRY_NAME_1=development",
        "-e", "SCHEMA_REGISTRY_URL_1=http://dev-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_2=staging",
        "-e", "SCHEMA_REGISTRY_URL_2=http://staging-registry:8082",
        "-e", "SCHEMA_REGISTRY_NAME_3=production", 
        "-e", "SCHEMA_REGISTRY_URL_3=http://prod-registry:8083",
        "-e", "VIEWONLY_3=true",
        "-e", "SLIM_MODE=true",
        "aywengo/kafka-schema-reg-mcp:stable"
      ],
      "env": {
        "GITHUB_CLIENT_ID": "your_github_client_id",
        "GITHUB_CLIENT_SECRET": "your_github_client_secret"
      }
    }
  }
}
```

## 📦 Services Overview

| Service | URL | Purpose | Auth Required |
|---------|-----|---------|---------------|
| **Demo UI** | http://localhost:3000 | Interactive web interface | GitHub OAuth |
| **MCP Server** | http://localhost:38000 | Main API endpoint | GitHub Token |
| **Dev Registry** | http://localhost:8081 | Development schema registry | Internal |
| **Staging Registry** | http://localhost:8082 | Staging schema registry | Internal |
| **Production Registry** | http://localhost:8083 | Production schema registry | Internal |
| **Monitoring** | http://localhost:9090 | Prometheus metrics | None |
| **Dashboards** | http://localhost:3001 | Grafana dashboards | admin/admin123 |

## 🔍 Testing GitHub OAuth

### Get Your GitHub Token
```bash
# Personal Access Token (for testing)
# Go to GitHub Settings → Developer settings → Personal access tokens
# Create token with repo, public_repo, and admin:org scopes
export GITHUB_TOKEN="ghp_your_token_here"
```

### Test Different Permission Levels
```bash
# Test public access
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  http://localhost:38000/subjects

# Test write access
curl -X POST http://localhost:38000/schemas \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"registry":"development","subject":"test","schema":{"type":"string"}}'

# Check your permissions
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  http://localhost:38000/auth/user
```

## 🚀 Benefits of GitHub OAuth Integration

### For Developers
- **Familiar Flow**: Same OAuth they use for other dev tools
- **No Extra Accounts**: Use existing GitHub identity
- **Permission Inheritance**: Automatically inherit org/team permissions
- **Cross-IDE Support**: Works with any MCP-compatible client

### For Organizations  
- **Centralized Access**: Manage all access through GitHub teams
- **Audit Trail**: GitHub provides complete authentication logs
- **Fine-Grained Control**: Repo-level and org-level permissions
- **Cost Effective**: No separate OAuth infrastructure needed

### For Demo Experience
- **Realistic**: Authentic OAuth flow developers expect
- **Simplified Setup**: No separate OAuth provider to configure
- **Better Performance**: Faster startup without Keycloak
- **Universal Access**: Works with any MCP client

## 🎯 Try It With Your Preferred IDE

Once the demo is running, you can use it with any MCP-compatible client:

### Quick Test Commands

```
"List all schema contexts"
"Show me subjects in the development registry"
"Register a test schema with name and email fields"
"Check what registries are available"
"Export all schemas from the ecommerce context"
"Migrate a schema from staging to production"
```

### Client-Specific Features

| Client | Special Features |
|--------|------------------|
| **Claude Desktop** | Native conversational interface |
| **VS Code Copilot** | Agent mode with tool integration |
| **Cursor** | One-click server installation |
| **JetBrains** | Codebase-aware schema operations |

## 📚 Next Steps

1. **Create GitHub Organization**: `kafka-schema-reg-mcp-demos`
2. **Set Up Teams**: Configure read/write/admin teams
3. **Deploy to Cloud**: Public demo with custom domain
4. **Community Building**: Invite users to try the demo
5. **Cross-IDE Testing**: Validate with multiple MCP clients

---

🎉 **Experience the power of Schema Registry management with familiar GitHub authentication and your favorite IDE!**

📱 **Join our GitHub organization**: [kafka-schema-reg-mcp-demos](https://github.com/kafka-schema-reg-mcp-demos)

⭐ **Star this repository** to help others discover this demo!

🐛 **Report issues**: [GitHub Issues](https://github.com/kafka-schema-reg-mcp-demos/demo-deployment/issues)
