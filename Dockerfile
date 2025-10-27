FROM python:3.12-slim

# Avoid prompts, reduce image size, be explicit with --no-install-recommends
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      build-essential \
      libffi-dev \
      curl \
      wget \
      ca-certificates \
      default-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Install ANTLR4 tool
RUN wget https://www.antlr.org/download/antlr-4.13.1-complete.jar -O /usr/local/lib/antlr-4.13.1-complete.jar && \
    printf '%s\n' '#!/bin/sh' 'exec java -jar /usr/local/lib/antlr-4.13.1-complete.jar "$@"' > /usr/local/bin/antlr4 && \
    chmod +x /usr/local/bin/antlr4

ENV CLASSPATH=".:/usr/local/lib/antlr-4.13.1-complete.jar:$CLASSPATH"

WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy grammar files and generate parser
COPY grammar/ ./grammar/
RUN cd grammar && antlr4 -Dlanguage=Python3 -visitor -no-listener C.g4 && cd ..

# Copy the rest of the code
COPY . .

ENV NEO4J_USER=neo4j
ENV NEO4J_PASSWORD=strongpass123
ENV PYTHONPATH=/app:$PYTHONPATH

EXPOSE 8501

CMD ["streamlit", "run", "app/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]

