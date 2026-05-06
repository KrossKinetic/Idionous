> **Note:** Idionous is currently a Work in Progress.

# Idionous

Idionous is a native macOS orchestration layer for local LLMs (e.g., Ollama). It provides a globally accessible, lightweight text-generation and Retrieval-Augmented Generation (RAG) pipeline without heavy desktop wrappers or Python dependencies.

## Motivation

Local models on consumer macOS hardware lack the reasoning depth to reliably execute autonomous, multi-step agent workflows. Forcing small models into agentic loops introduces severe latency and degrades output quality. 

Idionous strips away agentic bloat. It restricts the LLM to direct text generation and precise information retrieval. By feeding the model tightly scoped, user-controlled data—such as on-device OCR via `@screen` or manually curated SQLite vector chunks—Idionous maximizes the speed and reliability of local AI models on your existing hardware. It acts as a frictionless "second brain," not an autonomous agent.

## Core Architecture

* **Frontend:** SwiftUI and AppKit (borderless `NSPanel` for Spotlight-like global invocation).
* **LLM Communication:** `URLSession` REST calls to a local endpoint (default: Ollama `/api/chat`).
* **Vector Storage:** Native local SQLite database.
* **Vector Search:** Apple `Accelerate` (`vDSP`) for high-performance cosine similarity calculations on Apple Silicon.
* **Context Extraction:** Apple Vision Framework for on-device OCR.

## Key Features

* **Zero-Dependency Native RAG:** Replaces heavy vector databases (ChromaDB/FAISS) with native Swift + SQLite. Documents are chunked and embedded locally.
* **Isolated Memory:** * *Ephemeral RAM:* Chat history is strictly temporary. Clearing the chat purges all context.
  * *Persistent SQLite:* Long-term memory is read-only during conversations and strictly populated via explicit document uploads.
* **Contextual Tagging (`@screen`):** Native integration with macOS CoreGraphics and Vision. Typing `@screen` instantly captures the display, runs on-device OCR, and injects screen text into the prompt context.
* **Frictionless UX:** Triggered via a global system hotkey. Output is automatically copied to the macOS clipboard upon completion.

## Primary Use Cases

**1. The Context-Aware Email Reply (Instant OCR Integration)**
* **Scenario:** Drafting a formal reply to an email.
* **Workflow:** Press the global shortcut. Type: *"Read @screen and draft a polite reply confirming I will submit the project by Friday."* Idionous runs native OCR on your screen, generates the response locally, and copies it to your clipboard for immediate pasting.

**2. Curated Systems Documentation (Strict Manual RAG)**
* **Scenario:** Recalling an implementation detail from a specific PDF specification.
* **Workflow:** Trigger the shortcut from your IDE and ask: *"Based on my uploaded docs, what is the memory allocation constraint for this system call?"* Idionous queries the local SQLite vector database and instantly returns the exact chunk. It relies solely on your curated data, preventing hallucinated StackOverflow code.

**3. Cross-Referencing Active Work with Memory (OCR + RAG)**
* **Scenario:** Ensuring on-screen code matches your project specifications.
* **Workflow:** Trigger the shortcut and type: *"Does the implementation on @screen align with the testing methodology in my uploaded design document?"* The app isolates extracting active screen text (Vision) and retrieving the design document (SQLite) before combining them in the final prompt.

## How It Differs

1. **No Dependency Hell:** Compiles into a single `.app` bundle. Requires no Docker, Conda, or background package managers.
2. **Native Performance:** Built with native Apple frameworks, resulting in negligible idle RAM and CPU consumption compared to Electron apps.
3. **Strictly Non-Agentic:** Strips out web scraping and autonomous tool execution to maintain a highly predictable, constrained context window.
4. **Precision RAG Routing:** The `@screen` OCR tag bypasses vector search execution, preventing ambient screen text from distorting the cosine similarity retrieval of permanent documents.
