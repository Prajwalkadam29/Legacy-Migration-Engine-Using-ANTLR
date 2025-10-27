#!/bin/bash

# Setup script for ANTLR4 grammar generation
# Run this locally before building Docker image if you want to test

set -e

echo "🔧 Setting up ANTLR4 for C parser..."

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 11 or higher."
    exit 1
fi

# Create grammar directory if it doesn't exist
mkdir -p grammar

# Download ANTLR4 if not present
if [ ! -f "grammar/antlr-4.13.1-complete.jar" ]; then
    echo "📥 Downloading ANTLR 4.13.1..."
    wget https://www.antlr.org/download/antlr-4.13.1-complete.jar -O grammar/antlr-4.13.1-complete.jar
fi

# Generate Python3 parser from grammar
echo "🔨 Generating ANTLR parser from C.g4..."
cd grammar
java -jar antlr-4.13.1-complete.jar -Dlanguage=Python3 -visitor -no-listener C.g4
cd ..

echo "✅ ANTLR setup complete!"
echo "Generated files:"
ls -la grammar/*.py

echo ""
echo "You can now run:"
echo "  docker-compose up --build"
