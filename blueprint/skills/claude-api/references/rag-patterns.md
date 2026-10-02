# RAG Implementation Patterns

Reference guide for building Retrieval-Augmented Generation pipelines with the Claude API.

## Pipeline Overview

```
Documents → Chunk → Embed → Store → Query → Retrieve → Rerank → Prompt → Respond
```

## 1. Chunking Strategies

### Section-based (preferred for structured documents)
Split on semantic boundaries like markdown headers. Preserves context coherence.

```python
import re

def chunk_by_section(document_text):
    return re.split(r"\n## ", document_text)
```

### Character-based (with overlap)
Fixed-size windows with overlap for unstructured text.

```python
def chunk_by_char(text, chunk_size=150, chunk_overlap=20):
    chunks = []
    start_idx = 0
    while start_idx < len(text):
        end_idx = min(start_idx + chunk_size, len(text))
        chunks.append(text[start_idx:end_idx])
        start_idx = end_idx - chunk_overlap if end_idx < len(text) else len(text)
    return chunks
```

### Sentence-based (with overlap)
Groups sentences together, useful for articles and prose.

```python
def chunk_by_sentence(text, max_sentences=5, overlap=1):
    sentences = re.split(r"(?<=[.!?])\s+", text)
    chunks = []
    start = 0
    while start < len(sentences):
        end = min(start + max_sentences, len(sentences))
        chunks.append(" ".join(sentences[start:end]))
        start += max_sentences - overlap
    return chunks
```

**Which to choose:**
- Structured docs (markdown, HTML) → section-based
- Unstructured prose → sentence-based
- Raw text / logs → character-based

## 2. Embeddings

Use **VoyageAI** (`voyage-3-large`) with explicit `input_type` to distinguish document vs. query embeddings:

```python
import voyageai

client = voyageai.Client()

def generate_embedding(chunks, model="voyage-3-large", input_type="query"):
    is_list = isinstance(chunks, list)
    input_data = chunks if is_list else [chunks]
    result = client.embed(input_data, model=model, input_type=input_type)
    return result.embeddings if is_list else result.embeddings[0]
```

**Critical:** Always pass lists for bulk embedding to avoid rate-limiting from sequential single calls.

- `input_type="document"` when indexing content
- `input_type="query"` when embedding search queries

## 3. Vector Index

Store embeddings with cosine similarity search:

```python
class VectorIndex:
    def __init__(self, distance_metric="cosine", embedding_fn=None):
        self._embedding_fn = embedding_fn
        self._distance_metric = distance_metric
        self._vectors = []
        self._documents = []

    def add_documents(self, documents):
        """Bulk add — single API call for all embeddings."""
        contents = [doc["content"] for doc in documents]
        vectors = self._embedding_fn(contents)
        for vector, doc in zip(vectors, documents):
            self._vectors.append(vector)
            self._documents.append(doc)

    def search(self, query, k=3):
        """Search by string (auto-embedded) or raw vector."""
        if isinstance(query, str):
            query = self._embedding_fn(query)
        # Compute distances and return top-k
        distances = [self._cosine_distance(query, v) for v in self._vectors]
        indices = sorted(range(len(distances)), key=lambda i: distances[i])[:k]
        return [self._documents[i] for i in indices]
```

Documents must be dicts with a `"content"` key.

## 4. BM25 / Keyword Retrieval

Lexical search complements vector search — catches exact keyword matches that embeddings might miss.

```python
class BM25Index:
    def __init__(self, k1=1.5, b=0.75):
        self.k1 = k1
        self.b = b
        # Default tokenizer: lowercase + split on \W+
```

Key: BM25 scores are normalized to a distance-like value (closer to 0 = better match) so they fuse cleanly with vector distances.

## 5. Hybrid Retrieval with Reciprocal Rank Fusion

Combine vector (semantic) + BM25 (lexical) results:

```python
class Retriever:
    def __init__(self, *indexes):
        self._indexes = indexes

    def add_documents(self, documents):
        for index in self._indexes:
            index.add_documents(documents)

    def search(self, query_text, k=3, k_rrf=60):
        # Each index returns k*5 candidates
        all_results = [index.search(query_text, k=k*5) for index in self._indexes]

        # RRF: score = sum(1.0 / (k_rrf + rank)) across all indexes
        rrf_scores = {}
        for result_list in all_results:
            for rank, doc in enumerate(result_list):
                doc_id = doc["content"]
                rrf_scores[doc_id] = rrf_scores.get(doc_id, 0) + 1.0 / (k_rrf + rank)

        sorted_docs = sorted(rrf_scores.items(), key=lambda x: x[1], reverse=True)
        return sorted_docs[:k]
```

**Usage:**
```python
vector_index = VectorIndex(embedding_fn=generate_embedding)
bm25_index = BM25Index()
retriever = Retriever(bm25_index, vector_index)
retriever.add_documents([{"content": chunk} for chunk in chunks])
results = retriever.search("What were the Q3 revenue figures?", k=3)
```

## 6. Contextual Retrieval

Pre-process chunks with document context before embedding for better retrieval quality:

1. For each chunk, ask Claude to generate a short context sentence explaining where in the document it fits
2. Prepend that context to the chunk before embedding
3. This improves retrieval for chunks that lack standalone context

## 7. Prompting with Retrieved Context

```python
def rag_query(query, retriever, k=3):
    results = retriever.search(query, k=k)
    context = "\n\n---\n\n".join([r["content"] for r in results])

    response = anthropic_client.messages.create(
        model="claude-sonnet-5-5",  # current ids: https://docs.claude.com/en/docs/about-claude/models
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"""Answer based on the following context. If the context doesn't
contain enough information, say so.

<context>
{context}
</context>

Question: {query}"""
        }]
    )
    return response.content[0].text
```

## Best Practices Summary

1. **Chunk by semantic boundaries** when possible (sections > sentences > characters)
2. **Bulk embed** — never embed one document at a time
3. **Use hybrid retrieval** — vector alone misses keyword matches
4. **Set `input_type`** on embeddings (`"document"` vs `"query"`)
5. **Limit retrieved chunks** to fit within context window
6. **Use prompt caching** for the system prompt + context prefix
