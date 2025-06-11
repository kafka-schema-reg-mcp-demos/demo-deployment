#!/bin/bash

# Demo Data Setup Script for Kafka Schema Registry MCP Demo
# Downloads and loads demo schemas from demo-schemas repository

set -e

echo "📊 Loading Demo Schemas into Schema Registries"
echo "=============================================="
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

# Schema Registry endpoints
DEV_REGISTRY="http://localhost:8081"
STAGING_REGISTRY="http://localhost:8082"
PROD_REGISTRY="http://localhost:8083"

# Demo schemas repository
DEMO_SCHEMAS_REPO="https://github.com/kafka-schema-reg-mcp-demos/demo-schemas.git"
TEMP_DIR="/tmp/demo-schemas-$(date +%s)"

# Wait for registries to be ready
wait_for_registries() {
    print_info "Waiting for Schema Registries to be ready..."
    
    for registry in "$DEV_REGISTRY" "$STAGING_REGISTRY" "$PROD_REGISTRY"; do
        for i in {1..30}; do
            if curl -s "$registry/subjects" > /dev/null 2>&1; then
                print_success "Registry $registry is ready"
                break
            fi
            
            if [ $i -eq 30 ]; then
                print_error "Registry $registry failed to start within 5 minutes"
                exit 1
            fi
            
            sleep 10
        done
    done
}

# Download demo schemas
download_schemas() {
    print_info "Downloading demo schemas..."
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    git clone "$DEMO_SCHEMAS_REPO" "$TEMP_DIR" --quiet
    
    if [ ! -d "$TEMP_DIR" ]; then
        print_error "Failed to download demo schemas"
        exit 1
    fi
    
    print_success "Demo schemas downloaded to $TEMP_DIR"
}

# Register a schema to a registry
register_schema() {
    local registry_url="$1"
    local subject="$2"
    local schema_file="$3"
    local registry_name="$4"
    
    if [ ! -f "$schema_file" ]; then
        print_warning "Schema file not found: $schema_file"
        return 1
    fi
    
    # Read and escape the schema JSON
    schema_content=$(cat "$schema_file" | jq -c .)
    
    # Create the registration payload
    payload=$(jq -n --argjson schema "$schema_content" '{
        "schema": ($schema | tostring),
        "schemaType": "AVRO"
    }')
    
    # Register the schema
    response=$(curl -s -X POST \
        -H "Content-Type: application/vnd.schemaregistry.v1+json" \
        -d "$payload" \
        "$registry_url/subjects/$subject/versions")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        schema_id=$(echo "$response" | jq -r '.id')
        print_success "Registered $subject (ID: $schema_id) in $registry_name"
        return 0
    else
        print_warning "Failed to register $subject in $registry_name: $response"
        return 1
    fi
}

# Load schemas for a specific domain
load_domain_schemas() {
    local domain="$1"
    local context="$2"
    
    print_info "Loading $domain schemas..."
    
    if [ ! -d "$TEMP_DIR/$domain" ]; then
        print_warning "Domain directory not found: $domain"
        return
    fi
    
    # Find all schema directories in the domain
    for schema_dir in "$TEMP_DIR/$domain"/*; do
        if [ -d "$schema_dir" ]; then
            schema_name=$(basename "$schema_dir")
            subject="${context}.${schema_name}-value"
            
            # Load v1 into development
            if [ -f "$schema_dir/v1.avsc" ]; then
                register_schema "$DEV_REGISTRY" "$subject" "$schema_dir/v1.avsc" "development"
            fi
            
            # Load v1 into staging (simulating promotion)
            if [ -f "$schema_dir/v1.avsc" ]; then
                register_schema "$STAGING_REGISTRY" "$subject" "$schema_dir/v1.avsc" "staging"
            fi
            
            # Load v2 into development if it exists
            if [ -f "$schema_dir/v2.avsc" ]; then
                register_schema "$DEV_REGISTRY" "$subject" "$schema_dir/v2.avsc" "development"
            fi
            
            # Load v1 into production (simulating stable release)
            if [ -f "$schema_dir/v1.avsc" ]; then
                register_schema "$PROD_REGISTRY" "$subject" "$schema_dir/v1.avsc" "production"
            fi
            
            # Load v3 if it exists (only in dev)
            if [ -f "$schema_dir/v3.avsc" ]; then
                register_schema "$DEV_REGISTRY" "$subject" "$schema_dir/v3.avsc" "development"
            fi
        fi
    done
}

# Load evolution examples
load_evolution_examples() {
    print_info "Loading schema evolution examples..."
    
    evolution_dir="$TEMP_DIR/evolution-examples"
    if [ ! -d "$evolution_dir" ]; then
        print_warning "Evolution examples directory not found"
        return
    fi
    
    # Load backward compatibility examples
    if [ -d "$evolution_dir/backward" ]; then
        for schema_file in "$evolution_dir/backward"/*.avsc; do
            if [ -f "$schema_file" ]; then
                filename=$(basename "$schema_file" .avsc)
                subject="examples.backward-${filename}-value"
                register_schema "$DEV_REGISTRY" "$subject" "$schema_file" "development"
            fi
        done
    fi
    
    # Load forward compatibility examples
    if [ -d "$evolution_dir/forward" ]; then
        for schema_file in "$evolution_dir/forward"/*.avsc; do
            if [ -f "$schema_file" ]; then
                filename=$(basename "$schema_file" .avsc)
                subject="examples.forward-${filename}-value"
                register_schema "$DEV_REGISTRY" "$subject" "$schema_file" "development"
            fi
        done
    fi
    
    # Load full compatibility examples
    if [ -d "$evolution_dir/full" ]; then
        for schema_file in "$evolution_dir/full"/*.avsc; do
            if [ -f "$schema_file" ]; then
                filename=$(basename "$schema_file" .avsc)
                subject="examples.full-${filename}-value"
                register_schema "$DEV_REGISTRY" "$subject" "$schema_file" "development"
            fi
        done
    fi
}

# Display summary of loaded schemas
show_summary() {
    print_info "Schema Loading Summary"
    echo ""
    
    for registry_name in "Development" "Staging" "Production"; do
        case $registry_name in
            "Development") registry_url="$DEV_REGISTRY" ;;
            "Staging") registry_url="$STAGING_REGISTRY" ;;
            "Production") registry_url="$PROD_REGISTRY" ;;
        esac
        
        subjects=$(curl -s "$registry_url/subjects" | jq -r '.[]' | wc -l)
        echo "📊 $registry_name Registry: $subjects subjects"
        
        # Show first few subjects as examples
        echo "   Examples:"
        curl -s "$registry_url/subjects" | jq -r '.[]' | head -3 | while read subject; do
            versions=$(curl -s "$registry_url/subjects/$subject/versions" | jq length)
            echo "   - $subject ($versions versions)"
        done
        echo ""
    done
}

# Test schema access
test_schema_access() {
    print_info "Testing schema access..."
    
    # Test getting a schema from development
    dev_subjects=$(curl -s "$DEV_REGISTRY/subjects" | jq -r '.[]' | head -1)
    if [ -n "$dev_subjects" ]; then
        latest_schema=$(curl -s "$DEV_REGISTRY/subjects/$dev_subjects/versions/latest")
        if echo "$latest_schema" | jq -e '.schema' > /dev/null 2>&1; then
            print_success "Schema retrieval test passed"
        else
            print_warning "Schema retrieval test failed"
        fi
    fi
}

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_info "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main execution
main() {
    print_info "Starting demo data setup..."
    echo ""
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed. Please install jq first."
        exit 1
    fi
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        print_error "git is required but not installed. Please install git first."
        exit 1
    fi
    
    wait_for_registries
    download_schemas
    
    # Load domain-specific schemas
    load_domain_schemas "ecommerce" "ecommerce"
    load_domain_schemas "iot-platform" "iot"
    load_domain_schemas "fintech" "fintech"
    load_domain_schemas "saas-platform" "saas"
    
    # Load evolution examples
    load_evolution_examples
    
    # Show summary and test
    show_summary
    test_schema_access
    
    print_success "Demo data setup completed successfully!"
    echo ""
    echo "🎯 Next steps:"
    echo "  1. Visit http://localhost:3000 to explore the schemas"
    echo "  2. Try the MCP server at http://localhost:38000"
    echo "  3. Test schema operations with different registries"
    echo "  4. Experiment with schema evolution scenarios"
    echo ""
}

# Check if script is being run directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main "$@"
fi