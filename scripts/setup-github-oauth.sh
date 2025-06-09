#!/bin/bash

# GitHub OAuth Setup Script for Kafka Schema Registry MCP Demo
# This script helps configure GitHub OAuth for the demo environment

set -e

echo "🚀 Kafka Schema Registry MCP Demo - GitHub OAuth Setup"
echo "=========================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if required tools are installed
check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is required but not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is required but not installed. Please install Docker Compose first."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed. Please install curl first."
        exit 1
    fi
    
    print_success "All requirements satisfied"
}

# Guide user through GitHub OAuth app creation
setup_github_oauth() {
    print_info "Setting up GitHub OAuth Application..."
    echo ""
    
    echo "📋 Please create a GitHub OAuth App with these settings:"
    echo ""
    echo "1. Go to: https://github.com/settings/developers"
    echo "2. Click 'New OAuth App'"
    echo "3. Fill in the following:"
    echo "   - Application name: Kafka Schema Registry MCP Demo"
    echo "   - Homepage URL: http://localhost:3000"
    echo "   - Authorization callback URL: http://localhost:38000/auth/callback"
    echo "   - Description: Demo showcasing MCP server with GitHub OAuth"
    echo ""
    
    read -p "Press Enter when you've created the OAuth app..."
    
    echo ""
    print_info "Now we need your OAuth credentials..."
    
    # Get GitHub OAuth credentials
    read -p "Enter your GitHub Client ID: " GITHUB_CLIENT_ID
    read -s -p "Enter your GitHub Client Secret: " GITHUB_CLIENT_SECRET
    echo ""
    
    # Optional organization setup
    read -p "Enter your GitHub organization name (optional, press Enter to skip): " GITHUB_ORG
    if [ -z "$GITHUB_ORG" ]; then
        GITHUB_ORG="kafka-schema-mcp-demos"
        print_warning "Using default organization: $GITHUB_ORG"
    fi
    
    # Validate credentials
    if [ -z "$GITHUB_CLIENT_ID" ] || [ -z "$GITHUB_CLIENT_SECRET" ]; then
        print_error "GitHub Client ID and Secret are required!"
        exit 1
    fi
    
    print_success "GitHub OAuth credentials collected"
}

# Create environment file
create_env_file() {
    print_info "Creating environment configuration..."
    
    # Create .env file from template
    if [ ! -f ".env.github-oauth" ]; then
        print_error ".env.github-oauth template not found!"
        exit 1
    fi
    
    cp .env.github-oauth .env
    
    # Update with user's credentials
    sed -i.bak "s/your_github_client_id_here/$GITHUB_CLIENT_ID/g" .env
    sed -i.bak "s/your_github_client_secret_here/$GITHUB_CLIENT_SECRET/g" .env
    sed -i.bak "s/kafka-schema-mcp-demos/$GITHUB_ORG/g" .env
    
    # Clean up backup file
    rm -f .env.bak
    
    print_success "Environment file created (.env)"
}

# Start demo environment
start_demo() {
    print_info "Starting demo environment..."
    
    # Check if services are already running
    if docker-compose -f docker-compose.github-oauth.yml ps | grep -q "Up"; then
        print_warning "Some services are already running. Stopping them first..."
        docker-compose -f docker-compose.github-oauth.yml down
    fi
    
    # Start services
    print_info "Starting services (this may take 2-3 minutes)..."
    docker-compose -f docker-compose.github-oauth.yml up -d
    
    # Wait for services to be ready
    print_info "Waiting for services to be ready..."
    
    for i in {1..60}; do
        if curl -s http://localhost:38000/health > /dev/null 2>&1; then
            print_success "MCP Server is ready!"
            break
        fi
        
        if [ $i -eq 60 ]; then
            print_error "Services failed to start within 5 minutes"
            print_info "Check logs with: docker-compose -f docker-compose.github-oauth.yml logs"
            exit 1
        fi
        
        sleep 5
        echo -n "."
    done
    
    echo ""
    print_success "Demo environment is running!"
}

# Load demo data
load_demo_data() {
    print_info "Loading demo schemas..."
    
    if [ -f "./scripts/setup-demo-data.sh" ]; then
        chmod +x ./scripts/setup-demo-data.sh
        ./scripts/setup-demo-data.sh
        print_success "Demo data loaded successfully"
    else
        print_warning "Demo data script not found, skipping..."
    fi
}

# Test the setup
test_setup() {
    print_info "Testing the demo setup..."
    
    # Test health endpoint
    if curl -s http://localhost:38000/health | grep -q "healthy"; then
        print_success "✅ MCP Server health check passed"
    else
        print_error "❌ MCP Server health check failed"
    fi
    
    # Test registries endpoint
    if curl -s http://localhost:38000/registries | grep -q "development"; then
        print_success "✅ Multi-registry setup verified"
    else
        print_error "❌ Multi-registry setup failed"
    fi
    
    # Test OAuth info endpoint
    if curl -s http://localhost:38000/auth/info | grep -q "github"; then
        print_success "✅ GitHub OAuth integration verified"
    else
        print_error "❌ GitHub OAuth integration failed"
    fi
}

# Show access information
show_access_info() {
    echo ""
    print_success "🎉 Demo setup complete!"
    echo ""
    echo "📱 Access your demo at:"
    echo "   🌐 Demo UI:        http://localhost:3000"
    echo "   🔧 MCP Server:     http://localhost:38000"
    echo "   📊 Monitoring:     http://localhost:9090"
    echo "   📈 Dashboards:     http://localhost:3001 (admin/admin123)"
    echo ""
    echo "🔐 GitHub OAuth Configuration:"
    echo "   📱 Login URL:      http://localhost:3000/login"
    echo "   🏢 Organization:   $GITHUB_ORG"
    echo "   🔑 Client ID:      $GITHUB_CLIENT_ID"
    echo ""
    echo "🧪 Test the API:"
    echo "   curl http://localhost:38000/health"
    echo "   curl http://localhost:38000/registries"
    echo "   curl http://localhost:38000/auth/info"
    echo ""
    echo "📚 Next steps:"
    echo "   1. Visit http://localhost:3000 and sign in with GitHub"
    echo "   2. Try the demo scenarios in the documentation"
    echo "   3. Integrate with Claude Desktop using the provided config"
    echo "   4. Deploy to production when ready!"
    echo ""
}

# Claude Desktop configuration
show_claude_config() {
    print_info "Claude Desktop Configuration"
    echo ""
    echo "📋 Add this to your Claude Desktop config:"
    echo ""
    
    cat << EOF
{
  "mcpServers": {
    "kafka-schema-registry-demo": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "kafka-schema-mcp-demo",
        "-e", "ENABLE_AUTH=true",
        "-e", "AUTH_PROVIDER=github",
        "-e", "GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID",
        "-e", "GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET",
        "-e", "GITHUB_ORG=$GITHUB_ORG",
        "-e", "SCHEMA_REGISTRY_NAME_1=development",
        "-e", "SCHEMA_REGISTRY_URL_1=http://dev-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_2=staging",
        "-e", "SCHEMA_REGISTRY_URL_2=http://staging-registry:8081",
        "-e", "SCHEMA_REGISTRY_NAME_3=production",
        "-e", "SCHEMA_REGISTRY_URL_3=http://prod-registry:8081",
        "-e", "READONLY_3=true",
        "aywengo/kafka-schema-reg-mcp:stable"
      ]
    }
  }
}
EOF
    
    echo ""
    echo "💾 Save this to:"
    echo "   macOS: ~/Library/Application Support/Claude/claude_desktop_config.json"
    echo "   Linux: ~/.config/claude-desktop/config.json"
    echo ""
}

# Error handling
trap 'print_error "Setup interrupted!"; exit 1' INT TERM

# Main execution
main() {
    check_requirements
    setup_github_oauth
    create_env_file
    start_demo
    load_demo_data
    test_setup
    show_access_info
    show_claude_config
    
    print_success "🚀 GitHub OAuth demo setup complete!"
}

# Check if script is being run directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main "$@"
fi