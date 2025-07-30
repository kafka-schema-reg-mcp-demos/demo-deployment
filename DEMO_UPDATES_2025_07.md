# Demo Updates - July 2025

## 🚀 Updated to Latest MCP Server v2.1.1

We've updated all demo repositories to use the latest stable version of the Kafka Schema Registry MCP Server (v2.1.1), bringing significant performance improvements and new features to the demo environment.

### What's New

#### 🚀 SLIM_MODE Performance Optimization (Default Enabled)
- **Reduced tool overhead**: From 57+ tools to ~9 essential tools
- **Faster LLM responses**: Significantly improved response times
- **Lower costs**: Reduced token usage for AI operations
- **Ideal for demos**: Perfect balance of functionality and performance

#### 🤖 Enhanced Schema Operations
- **Interactive schema migration**: Smart migration with user preference elicitation
- **Automatic backups**: Pre-migration backup creation
- **Post-migration verification**: Comprehensive schema validation
- **Bulk operations wizard**: Guided workflows for complex operations

#### 🔒 Security & Compliance
- **SSL/TLS verification**: Explicit certificate verification for all connections
- **Custom CA support**: Enterprise environment compatibility
- **Secure logging**: Automatic credential masking in logs
- **MCP 2025-06-18 compliance**: Full protocol specification compliance

### Configuration Changes

1. **Docker Image**: Updated from `v2.0.0-rc1` to `stable`
2. **Environment Variable**: Changed `READONLY_3` to `VIEWONLY_3`
3. **New Feature**: Added `SLIM_MODE=true` by default for optimal performance

### Updated Files

- **demo-deployment/docker-compose.github-oauth.yml**: Updated to use `aywengo/kafka-schema-reg-mcp:stable`
- **demo-deployment/README.md**: Added SLIM_MODE documentation and latest features
- **demo-docs/README.md**: Updated with v2.1.1 features and performance optimizations

### For Demo Users

No action required! The demo will automatically use the latest version with improved performance. If you need advanced features like bulk migrations:

```bash
# Disable SLIM_MODE in your .env file
SLIM_MODE=false
```

### Links

- [Main MCP Server Repository](https://github.com/aywengo/kafka-schema-reg-mcp)
- [Full Changelog](https://github.com/aywengo/kafka-schema-reg-mcp/blob/main/CHANGELOG.md)
- [SLIM_MODE Documentation](https://github.com/aywengo/kafka-schema-reg-mcp#slim_mode-configuration-performance-optimization)

---

**Questions?** Open an issue in any of the demo repositories or the main MCP server repository.
