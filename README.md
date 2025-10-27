# Legacy Migration Engine (ANTLR Edition)

## What it does
- Parse C code into AST using **ANTLR4** (replacing libclang)
- Store AST in Neo4j graph database
- Vectorize AST nodes using Ollama embeddings
- Convert C code to OOP Python using LLaMA (via Groq or Ollama)
- Streamlit UI for upload/paste, visualize AST, download generated code

## Key Features
✅ **ANTLR4 Integration** - Robust C parsing with better error handling  
✅ **Neo4j Graph Storage** - Efficient AST storage and querying  
✅ **LLM-Powered Conversion** - Groq (fast) or Ollama (local) for code generation  
✅ **Vector Embeddings** - Semantic search on AST nodes  
✅ **Docker Compose** - One-command deployment  

---

## Prerequisites

### Required
- **Docker** and **Docker Compose**
- **Java 11+** (for ANTLR grammar generation)

### Optional (for local Ollama)
- **Ollama** installed locally ([ollama.com](https://ollama.com))
- Models: `ollama pull llama3.2` and `ollama pull nomic-embed-text`

### Optional (for Groq - faster)
- **Groq API Key** (free tier available at [groq.com](https://console.groq.com))

---

## 🛠️ Setup & Usage

### 1. Clone Repository
```bash
git clone https://github.com/your-username/legacy-migration-engine.git
cd legacy-migration-engine
```

### 2. Create Grammar Directory
```bash
mkdir -p grammar
```

### 3. Add C.g4 Grammar File
Create `grammar/C.g4` with the C grammar (provided in artifacts above).

### 4. Generate ANTLR Parser (Optional - done in Docker)

If you want to test locally first:
```bash
chmod +x setup_antlr.sh
./setup_antlr.sh
```

This will:
- Download ANTLR 4.13.1 JAR
- Generate Python parser from C.g4

> **Note**: The Dockerfile automatically generates the parser during build, so this step is optional.

### 5. Build & Start Containers
```bash
docker-compose up --build
```

This will:
- Start Neo4j at [http://localhost:7474](http://localhost:7474)
- Build app with ANTLR grammar
- Start Streamlit app at [http://localhost:8501](http://localhost:8501)

### 6. Access the Application

#### Streamlit Web UI
Open [http://localhost:8501](http://localhost:8501)

#### Neo4j Browser
Open [http://localhost:7474](http://localhost:7474)
- Username: `neo4j`
- Password: `strongpass123`

### 7. Stop Containers
```bash
docker-compose down
```

To also remove volumes (⚠️ deletes all Neo4j data):
```bash
docker-compose down -v
```

---

## 📁 Project Structure

```
legacy-migration-engine/
├── app/
│   └── streamlit_app.py          # Streamlit
